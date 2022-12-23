/* eslint-disable @typescript-eslint/no-explicit-any */
import { Message } from '@app/classes/chatbox/message';
import { GameMode } from '@app/classes/game/game-mode';
import { GameParameters } from '@app/classes/game/game-parameters';
import { PlayerInformations } from '@app/classes/player/player-informations';
import { EVENT_EASEL_UPDATED } from '@app/constants/game';
import { EVENT_AVAILABLE_ROOMS_UPDATED, EVENT_OBSERVABLE_ROOMS_UPDATED } from '@app/constants/room';
import * as SOCKET from '@app/constants/socket';
import { EVENT_RETURN_HINTS } from '@app/constants/socket';
import { ChatboxService } from '@app/services/chatbox/chatbox.service';
import { DictionaryService } from '@app/services/dictionary/dictionary.service';
import { GameService } from '@app/services/game/game.service';
import { RoomService } from '@app/services/room/room.service';
import { SocketCommunicationService } from '@app/services/socket-communication/socket-communication.service';
import * as http from 'http';
import { Server, Socket } from 'socket.io';
import { Service } from 'typedi';

@Service()
export class SocketManagerService {
    private sio: Server;

    constructor(
        private readonly roomService: RoomService,
        private readonly chatboxService: ChatboxService,
        private readonly gameService: GameService,
        private readonly socketCommunicationService: SocketCommunicationService,
        private readonly dictionaryService: DictionaryService,
    ) {}

    /**
     * Créé un serveur de communication (SocketIO)
     *
     * @param server Serveur HTTP
     */
    createSocketServer(server: http.Server): void {
        this.sio = new Server(server, { cors: { origin: '*', methods: ['GET', 'POST'] } });
        this.socketCommunicationService.setServer(this.sio);
    }

    /**
     * Initialise les événements du serveur
     */
    handleSockets(): void {
        this.sio.on('connection', (socket: Socket) => {
            socket.on(SOCKET.EVENT_ROOM_CREATE, (name: string, gameParameters: GameParameters) => {
                this.roomService.create({ name, id: socket.id }, gameParameters);
            });

            socket.on(SOCKET.EVENT_ROOM_CREATE_MOBILE, (name: string, gameParameters: any) => {
                this.roomService.create({ name, id: socket.id }, JSON.parse(gameParameters));
            });
            socket.on(SOCKET.EVENT_ROOM_START, () => {
                this.roomService.startGame(socket.id);
            });
            socket.on(SOCKET.EVENT_ROOM_CANCEL, () => {
                this.roomService.delete(socket.id);
            });
            socket.on(SOCKET.EVENT_ROOM_JOIN_REQUEST, (guest: unknown, roomId: string) => {
                if (typeof guest == 'string') {
                    this.roomService.joinRequest(JSON.parse(guest) as PlayerInformations, roomId);
                } else this.roomService.joinRequest(guest as PlayerInformations, roomId);
            });
            socket.on(SOCKET.EVENT_ROOM_ADD_OBSERVER, (roomId: string, observerName: string) => {
                this.roomService.addObserver(socket.id, roomId, observerName);
            });

            socket.on(SOCKET.EVENT_ROOM_CANCEL_JOIN_REQUEST, (roomId: string) => {
                this.roomService.cancelJoinRequest(roomId);
            });

            socket.on(SOCKET.EVENT_ROOM_ACCEPT_JOIN_REQUEST, (acceptedGuest: unknown) => {
                if (typeof acceptedGuest == 'string') {
                    this.roomService.acceptJoinRequest(socket.id, JSON.parse(acceptedGuest) as PlayerInformations);
                } else this.roomService.acceptJoinRequest(socket.id, acceptedGuest as PlayerInformations);
            });

            socket.on(SOCKET.EVENT_ROOM_REJECT_JOIN_REQUEST, (rejectedGuest: unknown) => {
                if (typeof rejectedGuest == 'string') {
                    this.roomService.rejectJoinRequest(socket.id, JSON.parse(rejectedGuest) as PlayerInformations);
                } else this.roomService.rejectJoinRequest(socket.id, rejectedGuest as PlayerInformations);
            });

            socket.on(SOCKET.EVENT_ROOM_ABANDON_JOIN_REQUEST, (abandonedGuestId: string, roomId: string) => {
                this.roomService.abandonJoinRequest(roomId, abandonedGuestId);
            });

            socket.on(SOCKET.EVENT_ROOM_AVAILABLE_ROOMS_REQUEST, (gameMode: GameMode) => {
                socket.emit(EVENT_AVAILABLE_ROOMS_UPDATED, this.roomService.getAvailableRooms(gameMode));
            });

            socket.on(SOCKET.EVENT_ROOM_OBSERVABLE_ROOMS_REQUEST, (gameMode: GameMode) => {
                socket.emit(EVENT_OBSERVABLE_ROOMS_UPDATED, this.roomService.getObservableRooms(gameMode));
            });
            // socket.on(SOCKET.EVENT_GAME_CREATE_SOLO, (name: string, gameParameters: GameParameters, level: VirtualPlayerLevel) => {
            //     this.gameService.createSoloGame({ name, id: socket.id }, gameParameters, level);
            // });
            socket.on(SOCKET.EVENT_CHATBOX_MESSAGE, (message: Message) => {
                this.chatboxService.handleMessage(message, socket.id);
            });
            socket.on(SOCKET.EVENT_GAME_SURRENDER, (gameId: string) => {
                this.roomService.surrender(gameId, socket.id);
            });

            socket.on(SOCKET.EVENT_QUIT_OBSERVER, (gameId: string) => {
                this.roomService.observerQuit(gameId, socket.id);
            });

            socket.on(SOCKET.EVENT_GET_HINTS, (gameId: string) => {
                const hints = this.gameService.hints(gameId, socket.id);
                socket.emit(EVENT_RETURN_HINTS, hints);
            });
            socket.on(SOCKET.EVENT_GET_DICTIONARY, (gameId: string, searchedWord: string) => {
                const dict = this.dictionaryService.getDictionaryByGameId(gameId);
                socket.emit(
                    SOCKET.EVENT_RETURN_DICTIONARY,
                    dict.words.filter((word) => word.startsWith(searchedWord)),
                );
            });

            socket.on(SOCKET.EVENT_DICTIONARY_UPDATE, () => {
                this.dictionaryService.updateAvailableDictionaries();
            });
            socket.on(SOCKET.EVENT_GET_EASEL, (targetId: string, gameId: string) => {
                const player = this.gameService.games.get(gameId)?.players.find((p) => p.getId() === targetId);
                if (player) this.socketCommunicationService.emitToSocket(socket.id, EVENT_EASEL_UPDATED, player.getEasel().getContent());
            });
            socket.on(SOCKET.EVENT_REPLACE_VIRTUAL_PLAYER, (playerId: string, gameId: string) => {
                this.roomService.replacePlayer(playerId, socket.id, gameId);
            });
            socket.on(SOCKET.EVENT_DISCONNECT, () => {
                this.gameService.surrenderAfterClosingTab(socket.id);
            });
        });
    }
}
