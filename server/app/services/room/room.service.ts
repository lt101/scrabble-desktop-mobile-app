import { GameMode } from '@app/classes/game/game-mode';
import { GameParameters } from '@app/classes/game/game-parameters';
import { Player } from '@app/classes/player/player';
import { PlayerInformations } from '@app/classes/player/player-informations';
import { Room } from '@app/classes/room/room';
import { RoomInformations } from '@app/classes/room/room-informations';
import * as ROOM from '@app/constants/room';
import { QUIT_GAME, RELOAD_END_GAME } from '@app/constants/socket';
import { NAMES } from '@app/constants/virtual-player';
import { DictionaryService } from '@app/services/dictionary/dictionary.service';
import { GameService } from '@app/services/game/game.service';
import { SocketCommunicationService } from '@app/services/socket-communication/socket-communication.service';
import { Service } from 'typedi';
import { v4 as uuidv4 } from 'uuid';
import { UpdateService } from '../update/update.service';

@Service()
export class RoomService {
    rooms: Map<string, Room>;

    constructor(
        private readonly socketCommunicationService: SocketCommunicationService,
        private readonly gameService: GameService,
        private readonly dictionaryService: DictionaryService,
        readonly updateService: UpdateService,
    ) {
        this.rooms = new Map<string, Room>();
        this.gameService.eventEmitter.on('delete_room', (gameId: string, gameMode: GameMode) => {
            this.socketCommunicationService.emitToRoom(gameId, QUIT_GAME);
            this.leaveRoom(gameId);
            this.rooms.delete(gameId);
            this.updateRooms(gameMode);
        });
    }

    /**
     * Retourne la liste des salle disponibles
     *
     * @param gameMode Mode de jeu
     * @returns Liste des salle disponibles
     */
    getAvailableRooms(gameMode: GameMode): RoomInformations[] {
        return Array.from(this.rooms.values())
            .filter((room) => this.isRoomAvailable(room.id) && room.parameters.mode === gameMode)
            .map((room) => {
                return {
                    id: room.id,
                    hostName: room.host.name,
                    parameters: {
                        dictionary: this.dictionaryService.getTitle(room.parameters.dictionary),
                        mode: room.parameters.mode,
                        timer: room.parameters.timer,
                        visibility: room.parameters.visibility,
                        password: room.parameters.password,
                    },
                    players: room.guests,
                    observers: room.observers,
                };
            });
    }

    /**
     * Retourne la liste des salle observables
     *
     * @param gameMode Mode de jeu
     * @returns Liste des salle observables disponibles
     */
    getObservableRooms(gameMode: GameMode): RoomInformations[] {
        return Array.from(this.rooms.values())
            .filter((room) => room.gameHasStarted && room.parameters.mode === gameMode && room.parameters.visibility === 'public')
            .map((room) => {
                return {
                    id: room.id,
                    hostName: room.host.name,
                    parameters: {
                        dictionary: this.dictionaryService.getTitle(room.parameters.dictionary),
                        mode: room.parameters.mode,
                        timer: room.parameters.timer,
                        visibility: room.parameters.visibility,
                        password: room.parameters.password,
                    },
                    players: room.guests,
                    observers: room.observers,
                };
            });
    }

    /**
     * Met à jour la liste des salle disponibles sur tous les clients connectés
     */
    updateRooms(gameMode: GameMode): void {
        this.socketCommunicationService.emitToBroadcast(ROOM.EVENT_AVAILABLE_ROOMS_UPDATED, this.getAvailableRooms(gameMode));
        this.socketCommunicationService.emitToBroadcast(ROOM.EVENT_OBSERVABLE_ROOMS_UPDATED, this.getObservableRooms(gameMode));
    }

    /**
     * Le joueur abandonne et met à jour les informations de la room
     */
    async surrender(gameId: string, socketId: string): Promise<void> {
        const room = this.rooms.get(gameId);
        const game = this.gameService.games.get(gameId);
        if (room && game) {
            await this.gameService.surrender(gameId, socketId);

            room.guests.splice(
                room.guests.findIndex((g) => g.id === socketId),
                1,
                game?.newVirtualPlayer,
            );

            if (socketId !== room.host.id) this.socketCommunicationService.leaveRoom(socketId, gameId);
            else this.socketCommunicationService.emitToSocket(socketId, RELOAD_END_GAME);
            this.updateRooms(room.parameters.mode);
        }
    }

    /**
     * L'observateur quitte la room
     */
    observerQuit(gameId: string, socketId: string): void {
        const room = this.rooms.get(gameId);
        const game = this.gameService.games.get(gameId);
        if (room && game) {
            game.observers.splice(
                game.observers.findIndex((g) => g.getId() === socketId),
                1,
            );

            room.observers.splice(
                room.observers.findIndex((g) => g.id === socketId),
                1,
            );

            this.socketCommunicationService.leaveRoom(socketId, gameId);
            this.updateRooms(room.parameters.mode);
        }
    }

    /**
     * Observateur remplace un joueur virtuel et met à jour les informations de la room
     */
    replacePlayer(playerId: string, socketId: string, gameId: string): void {
        const room = this.rooms.get(gameId);
        const game = this.gameService.games.get(gameId);

        if (room && game) {
            this.gameService.replacePlayer(playerId, socketId, gameId);
            room.guests.splice(
                room.guests.findIndex((g) => g.id === playerId),
                1,
                game?.newPlayerFromObserver,
            );
            room.observers.splice(
                room.observers.findIndex((obs) => obs.id === socketId),
                1,
            );

            this.updateRooms(room.parameters.mode);
            this.updateService.updateGrid(game);
        }
    }

    /**
     * Créé une salle
     *
     * @param host Informations du joueur hôte
     * @param gameParameters Paramètres de la partie
     */
    create(host: PlayerInformations, gameParameters: GameParameters): void {
        const room: Room = new Room(host.id, host, gameParameters);
        this.addVirtualPlayers(room);
        this.dictionaryService.useDictionary(host.id, room.parameters.dictionary);
        this.rooms.set(host.id, room);
        this.updateRooms(gameParameters.mode);
    }

    /**
     * Ajouter des joueurs virtuels au début lorsque la salle d'attente est cree
     *
     * @param room Identifiant de la salle (la salle)
     */
    addVirtualPlayers(room: Room) {
        for (let i = 0; i < ROOM.MAX_GUESTS; i++) room.addGuest({ name: this.generateRandomName(room), id: 'virtual-' + uuidv4() });
    }

    /**
     * Génère un random name différent des autres noms de la salle pour un joueur virtuel
     *
     * @param room Identifiant de la salle
     */
    generateRandomName(room: Room): string {
        let virtualPlayerName = '';
        do virtualPlayerName = NAMES[Math.floor(Math.random() * NAMES.length)];
        while (room.guests.some((guest) => guest.name === virtualPlayerName));
        return virtualPlayerName;
    }

    /**
     * Supprime une salle
     *
     * @param id Identifiant de la salle
     */
    delete(id: string): void {
        const room: Room | undefined = this.rooms.get(id);
        if (!room) return;
        if (room.isFull()) this.socketCommunicationService.emitToRoom(room.id, ROOM.EVENT_JOIN_REQUEST_REJECTED);
        this.dictionaryService.releaseDictionary(id, room.parameters.dictionary);
        this.leaveRoom(room.id);
        this.rooms.delete(id);
        this.updateRooms(room.parameters.mode);
    }

    /**
     * Permet aux invités de la room de quitter la room
     *
     * @param roomId Identifiant de la salle
     */
    leaveRoom(roomId: string) {
        const room: Room | undefined = this.rooms.get(roomId);

        if (room) {
            room.guests.forEach((g) => {
                this.socketCommunicationService.leaveRoom(g.id, room.id);
            });
        }
    }

    /**
     * Traite une requête d'un invité de rejoindre une salle
     *
     * @param guest Informations du joueur invité
     * @param id Identifiant de la salle
     */
    joinRequest(guest: PlayerInformations, id: string): void {
        const room: Room | undefined = this.rooms.get(id);
        if (room && this.isRoomAvailable(id)) {
            this.socketCommunicationService.emitToRoom(id, ROOM.EVENT_JOIN_REQUESTED, guest);
        } else {
            this.socketCommunicationService.emitToSocket(guest.id, ROOM.EVENT_JOIN_REQUEST_ABORTED, guest);
            this.updateRooms(room?.parameters.mode!);
        }
    }

    /**
     * Ajoute un observateur dans la liste d'observateurs pour la salle spécifique
     *
     * @param id Identifiant de la salle
     */
    addObserver(socketId: string, id: string, observerName: string): void {
        const room: Room | undefined = this.rooms.get(id);
        if (room) {
            this.socketCommunicationService.joinRoom(socketId, id);
            this.socketCommunicationService.emitToSocket(socketId, ROOM.EVENT_GAME_STARTED, { gameId: id, timer: room.parameters.timer });
            const game = this.gameService.games.get(id);
            game?.observers.push(new Player(observerName, socketId, []));
            room.observers.push({ id: socketId, name: observerName });
            if (game) this.gameService.updateService.updateClient(game, socketId, true);
            this.updateRooms(room.parameters.mode);
        }
    }

    /**
     * Annule la requête d'un joueur de rejoindre une salle
     *
     * @param id Identifiant de la salle
     */
    cancelJoinRequest(id: string): void {
        this.rooms.get(id)?.removeAllGuests();
        this.socketCommunicationService.emitToRoom(id, ROOM.EVENT_JOIN_REQUEST_CANCELED);
    }

    /**
     * Démarre la partie
     *
     * @param id Identifiant de la salle
     */
    startGame(id: string): void {
        const room: Room | undefined = this.rooms.get(id);
        if (room && room.canStart()) {
            room.gameHasStarted = true;
            this.socketCommunicationService.emitToRoom(id, ROOM.EVENT_GAME_STARTED, { gameId: id, timer: room.parameters.timer });
            this.gameService.createMultiplayerGame(room.parameters, room.host, room.guests);
            this.updateRooms(room.parameters.mode);
            this.socketCommunicationService.emitToRoom(id, 'room:game_started_mobile');
        }
    }

    /**
     * Accepte la requête d'un joueur de rejoindre une salle
     *
     * @param id Identifiant de la salle
     */
    acceptJoinRequest(id: string, acceptedGuest: PlayerInformations): void {
        const room: Room | undefined = this.rooms.get(id);
        if (room && !room.isFull()) {
            for (const [index, guest] of room.guests.entries()) {
                if (guest.id.includes('virtual')) {
                    room.guests.splice(index, 1, acceptedGuest);
                    break;
                }
            }
            this.socketCommunicationService.joinRoom(acceptedGuest.id, id);
            this.socketCommunicationService.emitToSocket(acceptedGuest.id, ROOM.EVENT_JOIN_REQUEST_ACCEPTED);
            this.socketCommunicationService.emitToSocket(id, ROOM.EVENT_CAN_START, room.canStart());
            this.updateRooms(room.parameters.mode);
        } else {
            this.socketCommunicationService.emitToSocket(id, ROOM.EVENT_JOIN_REQUEST_CANCELED);
        }
    }

    /**
     * Rejette la requête d'un joueur de rejoindre une salle
     *
     * @param id Identifiant de la salle
     */
    rejectJoinRequest(id: string, rejectedGuest: PlayerInformations): void {
        const room: Room | undefined = this.rooms.get(id);
        if (room) {
            this.socketCommunicationService.emitToSocket(rejectedGuest.id, ROOM.EVENT_JOIN_REQUEST_REJECTED);
            this.socketCommunicationService.leaveRoom(rejectedGuest.id, id);
        }
    }

    /**
     * Remplace le joueur invité ayant annulé sa demande par un joueur virtuel
     *
     * @param id Identifiant de la salle
     * @param abandonedGuestId Identifiant de l'invité ayant annulé sa demande pour rejoindre la salle
     */
    abandonJoinRequest(id: string, abandonedGuestId: string) {
        const room: Room | undefined = this.rooms.get(id);

        if (room) {
            for (const [index, guest] of room.guests.entries()) {
                if (guest.id === abandonedGuestId) room.guests.splice(index, 1, { name: this.generateRandomName(room), id: 'virtual-' + uuidv4() });
            }
            this.socketCommunicationService.emitToSocket(id, ROOM.EVENT_CAN_START, room.canStart());
            this.socketCommunicationService.emitToSocket(id, ROOM.EVENT_JOIN_REQUEST_ABANDONED, abandonedGuestId);
            this.socketCommunicationService.leaveRoom(abandonedGuestId, id);
            this.updateRooms(room.parameters.mode);
        }
    }

    /**
     * Indique si la salle est pleine (4 joueurs)
     *
     * @param roomId Identifiant de la salle
     * @returns
     */
    private isRoomAvailable(roomId: string): boolean {
        return this.rooms.has(roomId) && !(this.rooms.get(roomId)?.isFull() ?? true) && !this.rooms.get(roomId)?.gameHasStarted;
    }
}
