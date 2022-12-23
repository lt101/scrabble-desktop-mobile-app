import { Component, OnInit } from '@angular/core';
import { FormControl, FormGroup } from '@angular/forms';
import { MatDialog } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { GameMode } from '@app/classes/game/game-mode';
import { GameVisibility } from '@app/classes/game/game-visibility';
import { PlayerInformations } from '@app/classes/player/player-informations';
import { RoomInformations } from '@app/classes/room/room-informations';
import { RoomRequestStatus } from '@app/classes/room/room-request-status';
import { MULTIPLAYER_JOIN_URL, MULTIPLAYER_URL, SOLO_URL } from '@app/constants/routing';
import { AuthService } from '@app/services/authentication/auth-service.service';
import { GameService } from '@app/services/game/game.service';
import { MusicService } from '@app/services/music/music.service';
import { RoomService } from '@app/services/room/room.service';
import { TranslocoService } from '@ngneat/transloco';

@Component({
    selector: 'app-multiplayer-join-page',
    templateUrl: './multiplayer-join-page.component.html',
    styleUrls: ['./multiplayer-join-page.component.scss'],
})
export class MultiplayerJoinPageComponent implements OnInit {
    allAvailableRooms: RoomInformations[];
    privateAvailableRooms: RoomInformations[];
    publicAvailableRooms: RoomInformations[];
    observableRooms: RoomInformations[];
    message: string;
    isSelected: boolean = false;
    isWaiting: boolean = false;
    displayedColumns: string[] = ['hostName', 'timer', 'dictionary', 'button', 'name'];
    joinForm: FormGroup;
    soloRedirection: string;
    backLink: string;
    show: boolean = false;
    validPassword: boolean = true;
    selectedRoomId: string;
    musicOn: boolean = true;
    gameMode: GameMode;

    constructor(
        private readonly gameService: GameService,
        private readonly roomService: RoomService,
        readonly router: Router,
        public dialog: MatDialog,
        private readonly authService: AuthService,
        private readonly translocoService: TranslocoService,
        public readonly musicService: MusicService,
    ) {
        this.soloRedirection = this.router.url.replace(MULTIPLAYER_JOIN_URL, SOLO_URL);
        this.backLink = this.router.url.replace(MULTIPLAYER_JOIN_URL, MULTIPLAYER_URL);
    }

    ngOnInit(): void {
        this.joinForm = new FormGroup({
            password: new FormControl(''),
        });
        this.roomService.getAvailableRooms().subscribe(this.handleAvailableRoomsUpdated.bind(this));
        this.roomService.getObservableRooms().subscribe(this.handleObservableRoomsUpdated.bind(this));
        this.roomService.getJoinRequestGuest().subscribe(this.handleStatusUpdated.bind(this));
        this.roomService.updateAvailableRooms();
        this.roomService.updateObservableRooms();
        this.gameMode = this.router.url.includes('log2990') ? (this.gameMode = GameMode.LOG2990) : (this.gameMode = GameMode.CLASSIC);
    }

    hasError = (controlName: string, errorName: string) => {
        // eslint-disable-next-line no-invalid-this
        return this.joinForm.controls[controlName].hasError(errorName);
    };

    selectRoom(roomId: string): void {
        this.isSelected = true;
        this.selectedRoomId = roomId;
    }

    joinRequest(): void {
        const available = this.allAvailableRooms.find((room) => room.id === this.selectedRoomId);
        const observable = this.observableRooms.find((room) => room.id === this.selectedRoomId);

        if (available) {
            if (this.joinForm.value.password !== available?.parameters.password) {
                this.validPassword = false;
                return;
            }

            this.isWaiting = true;
            this.gameService.setPlayer(this.authService.userProfile.userName!);
            this.roomService.joinRequest(this.authService.userProfile.userName!, this.selectedRoomId);
        } else if (observable) {
            if (this.joinForm.value.password !== observable?.parameters.password) {
                this.validPassword = false;
                return;
            }
            this.gameService.setPlayer(this.authService.userProfile.userName!);
            this.roomService.addObserver(this.selectedRoomId, this.authService.userProfile.userName!);
        }
    }

    cancelJoinRequest(): void {
        this.isSelected = false;
        this.isWaiting = false;
        this.message = '';
        this.roomService.cancelJoinRequest(this.selectedRoomId);
    }

    abandonJoinRequest(): void {
        this.roomService.abandonJoinRequest(this.selectedRoomId);
    }

    getNumberOfPlayers(players: PlayerInformations[], type: string): number {
        if (type === 'virtual') return players.filter((p) => p.id.includes('virtual')).length;
        else return players.filter((p) => !p.id.includes('virtual')).length;
    }

    handleAvailableRoomsUpdated(availableRoomsUpdated: RoomInformations[]) {
        if (availableRoomsUpdated.findIndex((room) => room.id === this.selectedRoomId) === -1) this.isSelected = this.isWaiting = false;
        this.allAvailableRooms = [...availableRoomsUpdated];
        this.privateAvailableRooms = availableRoomsUpdated.filter((room) => room.parameters.visibility === GameVisibility.PRIVATE);
        this.publicAvailableRooms = availableRoomsUpdated.filter((room) => room.parameters.visibility === GameVisibility.PUBLIC);
    }

    handleObservableRoomsUpdated(observableRoomsUpdated: RoomInformations[]) {
        this.observableRooms = [...observableRoomsUpdated];
    }

    handleStatusUpdated(requestStatus: RoomRequestStatus): void {
        if (requestStatus === RoomRequestStatus.ABORTED) {
            this.translocoService.selectTranslate('multiplayerJoinPage.messageAborted').subscribe((translation) => {
                this.message = translation;
            });
        } else if (requestStatus === RoomRequestStatus.REJECTED) {
            this.translocoService.selectTranslate('multiplayerJoinPage.messageRejected').subscribe((translation) => {
                this.message = translation;
            });
            this.router.navigate([this.backLink]);
        } else if (requestStatus === RoomRequestStatus.ACCEPTED) {
            this.translocoService.selectTranslate('multiplayerJoinPage.messageAccepted').subscribe((translation) => {
                this.message = translation;
            });
        }
    }

    roomHasPassword(): boolean {
        let hasPassword: boolean = false;
        this.publicAvailableRooms.forEach((room) => {
            if (room.id === this.selectedRoomId) hasPassword = room.parameters.password !== '';
        });
        this.observableRooms.forEach((room) => {
            if (room.id === this.selectedRoomId) hasPassword = room.parameters.password !== '';
        });
        return hasPassword;
    }
    musicClick() {
        this.musicService.pauseMusic();
        this.musicOn = !this.musicOn;
    }

    showPassword() {
        this.show = !this.show;
    }
}
