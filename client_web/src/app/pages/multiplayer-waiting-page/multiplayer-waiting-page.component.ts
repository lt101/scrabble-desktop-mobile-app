import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { PlayerInformations } from '@app/classes/player/player-informations';
import { MULTIPLAYER_URL, MULTIPLAYER_WAITING_URL, SOLO_URL } from '@app/constants/routing';
import { MusicService } from '@app/services/music/music.service';
import { RoomService } from '@app/services/room/room.service';

@Component({
    selector: 'app-multiplayer-waiting-page',
    templateUrl: './multiplayer-waiting-page.component.html',
    styleUrls: ['./multiplayer-waiting-page.component.scss'],
})
export class MultiplayerWaitingPageComponent implements OnInit {
    guests: PlayerInformations[] = [];
    soloRedirection: string;
    backLink: string;
    canStart: boolean;
    visibility: string;
    musicOn: boolean = true;

    constructor(
        private readonly roomService: RoomService,
        private readonly router: Router,
        private readonly route: ActivatedRoute,
        public readonly musicService: MusicService,
    ) {}

    ngOnInit(): void {
        this.roomService.getJoinRequestHost().subscribe(this.handleJoinRequest.bind(this));
        this.roomService.getCanStart().subscribe(this.handleCanStart.bind(this));
        this.roomService.getAbandonedId().subscribe(this.handleAbandonedJoinRequest.bind(this));
        this.soloRedirection = this.router.url.replace(MULTIPLAYER_WAITING_URL, SOLO_URL);
        this.backLink = this.router.url.replace(MULTIPLAYER_WAITING_URL, MULTIPLAYER_URL);
        this.route.queryParams.subscribe((params) => {
            this.visibility = params.visibility;
        });
    }

    handleJoinRequest(guest: PlayerInformations): void {
        this.guests.push(guest);
        if (this.visibility === 'public') this.accept(guest);
    }

    handleCanStart(canStart: boolean): void {
        this.canStart = canStart;
    }

    handleAbandonedJoinRequest(abandonedId: string): void {
        this.removeGuest(abandonedId);
    }

    accept(acceptedGuest: PlayerInformations) {
        if (this.visibility === 'private') this.removeGuest(acceptedGuest.id);
        this.roomService.acceptJoinRequest(acceptedGuest);
    }

    reject(rejectedGuest: PlayerInformations) {
        this.removeGuest(rejectedGuest.id);
        this.roomService.rejectJoinRequest(rejectedGuest);
    }

    cancelRoom() {
        this.roomService.cancelRoom();
    }

    startGame() {
        this.roomService.startGame();
    }
    musicClick() {
        this.musicService.pauseMusic();
        this.musicOn = !this.musicOn;
    }
    private removeGuest(id: string): void {
        this.guests.splice(
            this.guests.findIndex((guest) => guest.id === id),
            1,
        );
    }
}
