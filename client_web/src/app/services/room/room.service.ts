import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { GameMode } from '@app/classes/game/game-mode';
import { GameParameters } from '@app/classes/game/game-parameters';
import { Grid } from '@app/classes/grid/grid';
import { PlayerInformations } from '@app/classes/player/player-informations';
import { RoomInformations } from '@app/classes/room/room-informations';
import { RoomRequestStatus } from '@app/classes/room/room-request-status';
import * as EVENT from '@app/constants/events';
import { GAME_PAGE_PATH } from '@app/constants/game';
import { CLASSIC, LOG2990 } from '@app/constants/room';
import { GameService } from '@app/services/game/game.service';
import { GridService } from '@app/services/grid/grid/grid.service';
import { SocketManagerService } from '@app/services/socket-manager/socket-manager.service';
import { IpcRenderer } from 'electron';
import { Observable, Subject } from 'rxjs';

@Injectable({
    providedIn: 'root',
})
export class RoomService {
    private joinRequestHost: Subject<PlayerInformations>;
    private joinRequestGuest: Subject<RoomRequestStatus>;
    private availableRooms: Subject<RoomInformations[]>;
    private observableRooms: Subject<RoomInformations[]>;
    private canStart: Subject<boolean>;
    private abandonedId: Subject<string>;

    constructor(
        private readonly socketManagerService: SocketManagerService,
        private readonly gameService: GameService,
        private readonly gridService: GridService,
        private readonly router: Router,
    ) {
        this.joinRequestHost = new Subject<PlayerInformations>();
        this.joinRequestGuest = new Subject<RoomRequestStatus>();
        this.availableRooms = new Subject<RoomInformations[]>();
        this.observableRooms = new Subject<RoomInformations[]>();
        this.canStart = new Subject<boolean>();
        this.abandonedId = new Subject<string>();

        this.socketManagerService.connect();
        this.handleEvents();
    }

    /**
     * Créer une salle
     *
     * @param name Nom du joueur
     * @param parameters Paramètres de la partie
     */
    createRoom(name: string, parameters: GameParameters): void {
        this.gameService.setPlayer(name);
        this.socketManagerService.emit(EVENT.ROOM_CREATE, name, parameters);
    }

    /**
     * Annule la salle
     */
    cancelRoom(): void {
        this.socketManagerService.emit(EVENT.ROOM_CANCEL);
    }

    /**
     * Démarre une partie
     */
    startGame(): void {
        this.socketManagerService.emit(EVENT.ROOM_GAME_START);
    }

    /**
     * Demande une mise à jour la liste des salles disponibles
     */
    updateAvailableRooms(): void {
        const gameMode = this.router.url.includes('log2990') ? GameMode.LOG2990 : GameMode.CLASSIC;
        this.socketManagerService.emit(EVENT.ROOM_AVAILABLE_ROOMS_REQUEST, gameMode);
    }

    /**
     * Demande une mise à jour la liste des salles observables disponibles
     */
    updateObservableRooms(): void {
        const gameMode = this.router.url.includes('log2990') ? GameMode.LOG2990 : GameMode.CLASSIC;
        this.socketManagerService.emit(EVENT.ROOM_OBSERVABLE_ROOMS_REQUEST, gameMode);
    }

    /**
     * Accepte la demande de rejoindre la salle
     */
    acceptJoinRequest(acceptedGuest: PlayerInformations): void {
        this.socketManagerService.emit(EVENT.ROOM_JOIN_REQUEST_ACCEPT, acceptedGuest);
    }

    /**
     * Rejette la demande de rejoindre la salle
     */
    rejectJoinRequest(rejectedGuest: PlayerInformations): void {
        this.socketManagerService.emit(EVENT.ROOM_JOIN_REQUEST_REJECT, rejectedGuest);
    }

    /**
     * Abandonne la demande de rejoindre la salle lorsque l'invité quitte la page de salle d'attente
     */
    abandonJoinRequest(roomId: string) {
        this.socketManagerService.emit(EVENT.ROOM_JOIN_REQUEST_ABANDON, this.socketManagerService.getId(), roomId);
    }

    /**
     * Demande à rejoindre une salle
     *
     * @param name Nom du joueur
     * @param roomId Identifiant de la salle
     */
    joinRequest(name: string, roomId: string): void {
        this.socketManagerService.emit(EVENT.ROOM_JOIN_REQUEST, { id: this.socketManagerService.getId(), name }, roomId);
    }

    /**
     * Ajouter un nouveau observateur qui observe la partie
     *
     */
    addObserver(roomId: string, name: string): void {
        this.socketManagerService.emit(EVENT.ROOM_ADD_OBSERVER, roomId, name);
    }

    /**
     * Annule la demande de rejoindre une salle
     *
     * @param roomId Identifiant de la salle
     */
    cancelJoinRequest(roomId: string): void {
        this.socketManagerService.emit(EVENT.ROOM_JOIN_REQUEST_CANCEL, roomId);
    }

    /**
     * Gère les évènements
     */
    handleEvents(): void {
        this.socketManagerService.on(EVENT.ROOM_JOIN_REQUESTED, this.handleJoinRequest.bind(this));
        this.socketManagerService.on(EVENT.ROOM_JOIN_REQUEST_CANCELED, this.handleJoinRequestCancelled.bind(this));
        this.socketManagerService.on(EVENT.ROOM_JOIN_REQUEST_ACCEPTED, this.handleJoinRequestAccepted.bind(this));
        this.socketManagerService.on(EVENT.ROOM_JOIN_REQUEST_REJECTED, this.handleJoinRequestRejected.bind(this));
        this.socketManagerService.on(EVENT.ROOM_JOIN_REQUEST_ABORTED, this.handleJoinRequestAborted.bind(this));
        this.socketManagerService.on(EVENT.ROOM_JOIN_REQUEST_ABANDONED, this.handleJoinRequestAbandoned.bind(this));
        this.socketManagerService.on(EVENT.ROOM_AVAILABLE_ROOMS_UPDATED, this.handleAvailableRoomsUpdated.bind(this));
        this.socketManagerService.on(EVENT.ROOM_OBSERVABLE_ROOMS_UPDATED, this.handleObservableRoomsUpdated.bind(this));
        this.socketManagerService.on(EVENT.ROOM_GAME_STARTED, this.handleGameStarted.bind(this));
        this.socketManagerService.on(EVENT.ROOM_CAN_START, this.handleCanStart.bind(this));
        this.socketManagerService.on(EVENT.RELOAD_END_GAME, this.handleReload.bind(this));
    }
    // eslint-disable-next-line @typescript-eslint/member-ordering
    private ipc: IpcRenderer | undefined = void 0;
    /**
     * Gère les requêtes de rejoindre une salle
     *
     * @param guest Informations du joueur invité
     */
    handleJoinRequest(guest: PlayerInformations): void {
        this.joinRequestHost.next(guest);
    }

    /**
     * Gère l'annulation d'une requête de rejoindre une salle
     */
    handleJoinRequestCancelled(): void {
        this.joinRequestHost.next(undefined);
    }

    /**
     * Gère l'acceptation de la demande de rejoindre une salle
     */
    handleJoinRequestAccepted(): void {
        this.joinRequestGuest.next(RoomRequestStatus.ACCEPTED);
    }

    /**
     * Gère le rejet de la demande de rejoindre une salle
     */
    handleJoinRequestRejected(): void {
        this.joinRequestGuest.next(RoomRequestStatus.REJECTED);
    }

    /**
     * Gère la déconnexion du joueur invité
     */
    handleJoinRequestAborted(): void {
        this.joinRequestGuest.next(RoomRequestStatus.ABORTED);
    }

    /**
     * Gère lorsque le joueur invité clique sur annuler et qu'il faut l'enlever de la liste des joueurs
     */
    handleJoinRequestAbandoned(id: string): void {
        this.abandonedId.next(id);
    }

    /**
     * Met à jour la liste des salles disponibles
     *
     * @param availableRooms Liste des salles disponibles
     */
    handleAvailableRoomsUpdated(availableRooms: RoomInformations[]): void {
        this.availableRooms.next(availableRooms);
    }

    /**
     * Met à jour la liste des salles observables disponibles
     *
     * @param observableRooms Liste des salles observables disponibles
     */
    handleObservableRoomsUpdated(observableRooms: RoomInformations[]): void {
        this.observableRooms.next(observableRooms);
    }

    /**
     * Démarre le jeu
     *
     * @param informations Informations de la partie
     */
    handleGameStarted(informations: { gameId: string; timer: number }): void {
        this.gameService.gameId = informations.gameId;
        this.gameService.setTimerDuration(informations.timer);
        this.changeLocation();
    }

    /**
     * Vérifier si la partie peut démarrer
     *
     * @param canStart Booléen pour savoir si on peut commencer la partie ou non
     */
    handleCanStart(canStart: boolean): void {
        this.canStart.next(canStart);
    }

    /**
     * Reload la page du client lorsque la partie termine (abandon, fin de partie)
     */
    handleReload(): void {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        console.log('reload');
        this.gridService.grid = new Grid();
        this.ipc = (window as any).require('electron').ipcRenderer;
        this.ipc?.send('reload');
    }

    /**
     * Change l'url de la page
     */
    changeLocation() {
        const query = this.getGameMode() === GameMode.LOG2990 ? LOG2990 : CLASSIC;
        this.router.navigate([GAME_PAGE_PATH], { queryParams: { mode: query } });
    }

    /**
     * Retourne un observable des informations du joueur invité
     *
     * @returns Observable des informations du joueur invité
     */
    getJoinRequestHost(): Observable<PlayerInformations> {
        return this.joinRequestHost.asObservable();
    }

    /**
     * Retourne un observable sur les informations de la requête de rejoindre une salle
     *
     * @returns Observable des informations de la salle
     */
    getJoinRequestGuest(): Observable<RoomRequestStatus> {
        return this.joinRequestGuest.asObservable();
    }

    /**
     * Retourne un observable sur la les salles disponibles
     *
     * @returns Observable des informations des salles disponibles
     */
    getAvailableRooms(): Observable<RoomInformations[]> {
        return this.availableRooms.asObservable();
    }

    /**
     * Retourne un observable sur la les salles observables
     *
     * @returns Observable des informations des salles observables
     */
    getObservableRooms(): Observable<RoomInformations[]> {
        return this.observableRooms.asObservable();
    }

    /**
     *
     * Retourne un observable sur la variable canStart
     * @returns le booléen canStart
     */
    getCanStart(): Observable<boolean> {
        return this.canStart.asObservable();
    }

    /**
     * Retourne un observable sur le id du joueur qui abandonne sa requete de joindre une partie (bouton annuler invité)
     * @returns le id du joueur qui abandonne la requete
     */
    getAbandonedId(): Observable<string> {
        return this.abandonedId.asObservable();
    }

    /**
     * @returns le mode de jeu
     */
    getGameMode(): GameMode {
        return this.router.url.includes(LOG2990) ? GameMode.LOG2990 : GameMode.CLASSIC;
    }
}
