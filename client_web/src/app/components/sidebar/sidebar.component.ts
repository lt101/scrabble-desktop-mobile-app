import { Component, OnInit } from '@angular/core';
import { ThemePalette } from '@angular/material/core';
import { ProgressSpinnerMode } from '@angular/material/progress-spinner';
import { SidebarInformations, SidebarPlayerInformations } from '@app/classes/sidebar/sidebar-informations';
import { UserProfile } from '@app/classes/user-profile/user-profile';
import { HUNDRED_PERCENT, MAX_ONE_DIGIT, ONE_MINUTE_IN_SECONDS } from '@app/constants/timer';
import { GameService } from '@app/services/game/game.service';
import { SidebarService } from '@app/services/sidebar/sidebar.service';
import { SocketManagerService } from '@app/services/socket-manager/socket-manager.service';
import { TimerService } from '@app/services/timer/timer.service';
import { TranslocoService } from '@ngneat/transloco';

@Component({
    selector: 'app-sidebar',
    templateUrl: './sidebar.component.html',
    styleUrls: ['./sidebar.component.scss'],
})
export class SidebarComponent implements OnInit {
    players: SidebarPlayerInformations[] = [];
    reserveSize: number;
    color: ThemePalette;
    mode: ProgressSpinnerMode;
    value: number;
    progressSpinnerValue: number;
    currentPlayerId: string;
    sidebarInformations: SidebarInformations;
    userProfiles: UserProfile[];
    userStats: string;
    isObserver: boolean = false;

    constructor(
        public sideBarService: SidebarService,
        public socketManagerService: SocketManagerService,
        public gameService: GameService,
        public timerService: TimerService,
        private readonly translocoService: TranslocoService,
    ) {
        this.color = 'primary';
        this.mode = 'determinate';
        this.value = ONE_MINUTE_IN_SECONDS;
        this.progressSpinnerValue = ONE_MINUTE_IN_SECONDS;
    }

    ngOnInit(): void {
        this.setupTimer();
        this.sideBarService.getUserProfiles().subscribe((userProfiles: UserProfile[]) => {
            this.userProfiles = userProfiles;
        });
    }

    setupTimer(): void {
        this.timerSetUp();
        this.sideBarService.getSidebarInformations().subscribe((sidebarInformations: SidebarInformations) => {
            this.players = [...sidebarInformations.players];
            // this.userStats = this.players[0].playerName;
            this.reserveSize = sidebarInformations.reserveSize;
            this.gameService.setCurrentPlayer(sidebarInformations.currentPlayerId);

            this.currentPlayerId = this.gameService.currentPlayerId;

            this.isObserver = sidebarInformations.isObserver;
            if (!sidebarInformations.isObserver) this.resetTimer(this.timerService.time);
        });

        this.timerService.getTime().subscribe((time: number) => {
            this.setTimer(time);
            this.value = HUNDRED_PERCENT - (this.timerService.time / this.timerService.duration) * HUNDRED_PERCENT;
            this.progressSpinnerValue = (this.timerService.time / this.timerService.duration) * HUNDRED_PERCENT;
        });
    }

    setTimer(numberOfSeconds: number): void {
        const timer = document.getElementById('timer') as HTMLElement;
        if (!timer) {
            clearInterval(this.timerService.timerInterval);
            return;
        }
        if (numberOfSeconds < 0) {
            timer.innerHTML = '0 : 00';
        } else {
            const minutes: number = Math.floor(numberOfSeconds / ONE_MINUTE_IN_SECONDS);
            timer.innerHTML = `${minutes} : ${
                numberOfSeconds % ONE_MINUTE_IN_SECONDS === 0
                    ? '00'
                    : numberOfSeconds % ONE_MINUTE_IN_SECONDS > 0 && numberOfSeconds % ONE_MINUTE_IN_SECONDS <= MAX_ONE_DIGIT
                    ? '0' + (numberOfSeconds % ONE_MINUTE_IN_SECONDS)
                    : numberOfSeconds % ONE_MINUTE_IN_SECONDS
            }`;
        }
    }

    resetTimer(time: number): void {
        if (time !== 0) this.timerService.resetTimer();
    }

    timerSetUp(): void {
        this.timerService.setDuration(this.gameService.getTimerDuration());
        this.timerService.startTimer();
    }

    observeEasel(targetId: string): void {
        this.gameService.observeEasel(targetId);
    }

    replacePlayer(playerId: string): void {
        this.gameService.replacePlayer(playerId);
    }

    statsToStringFR(gamePlayed: number, gameWon: number, gameLost: number, grade: string): string {
        let ratio: number;
        if ((gameWon == 0 && gameLost == 0) || gameLost == 0) {
            ratio = 0;
        } else {
            ratio = gameWon / gameLost;
        }
        return `Nombre de parties jouées : ${gamePlayed}
        Ratio victoire/défaite : ${ratio}
        Grade :  ${grade}`;
    }

    statsToStringEN(gamePlayed: number, gameWon: number, gameLost: number, grade: string): string {
        let ratio: number;
        if ((gameWon == 0 && gameLost == 0) || gameLost == 0) {
            ratio = 0;
        } else {
            ratio = gameWon / gameLost;
        }
        return `Number of games played : ${gamePlayed}
        Win/loss ratio : ${ratio}
        Rank :  ${grade}\n`;
    }

    statsView(index: number): string {
        for (let i = 0; i < 4; i++) {
            if (this.userProfiles[i] != undefined) {
                if (this.players[index].playerName == this.userProfiles[i].userName!) {
                    if (this.translocoService.getActiveLang() == 'fr') {
                        return this.statsToStringFR(
                            this.userProfiles[i].gamePlayed!,
                            this.userProfiles[i].gameWon!,
                            this.userProfiles[i].gameLost!,
                            this.userProfiles[i].grade!,
                        );
                    } else {
                        return this.statsToStringEN(
                            this.userProfiles[i].gamePlayed!,
                            this.userProfiles[i].gameWon!,
                            this.userProfiles[i].gameLost!,
                            this.userProfiles[i].grade!,
                        );
                    }
                }
            }
        }
        if (this.translocoService.getActiveLang() == 'fr') {
            return 'Joueur virtuel';
        } else {
            return 'Virtual player';
        }
    }
}
