import { Component, Input, OnInit } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { DictionaryInformations } from '@app/classes/admin/dictionary-informations';
import { GameMode } from '@app/classes/game/game-mode';
import { GameType } from '@app/classes/game/game-type';
import { GameVisibility } from '@app/classes/game/game-visibility';
import { VirtualPlayerLevel } from '@app/classes/virtual-player/virtual-player-level';
import { DICTIONARY_DEFAULT } from '@app/constants/admin';
import { MusicService } from '@app/services/music/music.service';
import {
    LEVEL_DEFAULT,
    LEVEL_OPTIONS,
    PASSWORD_MAX_LENGTH,
    TIMER_DEFAULT,
    TIMER_OPTIONS,
    VISIBILITY_DEFAULT,
    VISIBILITY_OPTIONS,
} from '@app/constants/create-game';
import { GAME_CREATE_SOLO } from '@app/constants/events';
import { CREATE_URL, GAME_PAGE_PATH } from '@app/constants/game';
import { AuthService } from '@app/services/authentication/auth-service.service';
import { GameService } from '@app/services/game/game.service';
import { RoomService } from '@app/services/room/room.service';
import { SocketManagerService } from '@app/services/socket-manager/socket-manager.service';

@Component({
    selector: 'app-create-game',
    templateUrl: './create-game.component.html',
    styleUrls: ['./create-game.component.scss'],
})
export class CreateGameComponent implements OnInit {
    @Input() gameType: GameType;
    timer: number = TIMER_DEFAULT;
    level: VirtualPlayerLevel = LEVEL_DEFAULT;
    timerOptions = TIMER_OPTIONS;
    dictionary: string = DICTIONARY_DEFAULT;
    dictionaryOptions: { name: string; value: string }[] = [];
    visibility: GameVisibility = VISIBILITY_DEFAULT;
    visibilityOptions = VISIBILITY_OPTIONS;
    levelOptions = LEVEL_OPTIONS;
    confirmed: boolean;
    backLink: string;
    paramsForm: FormGroup;
    show: boolean = false;
    password: string = '';
    isObjectivesMode: boolean = false;
    constructor(
        private readonly router: Router,
        private readonly roomService: RoomService,
        private readonly gameService: GameService,
        private readonly socketManagerService: SocketManagerService,
        private readonly authService: AuthService,
        private readonly musicService: MusicService,
    ) {}
    ngOnInit(): void {
        this.gameService.updateAvailableDictionaries();
        this.backLink =
            this.gameType === GameType.SOLO
                ? this.router.url.substring(0, this.router.url.length - 'solo'.length)
                : this.router.url.substring(0, this.router.url.length - CREATE_URL.length);
        this.paramsForm = new FormGroup({
            dictionary: new FormControl(DICTIONARY_DEFAULT),
            timer: new FormControl(TIMER_DEFAULT),
            visibility: new FormControl(VISIBILITY_DEFAULT),
            password: new FormControl('', [Validators.maxLength(PASSWORD_MAX_LENGTH)]),
        });
        this.gameService.getAvailableDictionaries().subscribe((dictionaries: DictionaryInformations[]) => {
            this.dictionaryOptions = dictionaries.map((dictionary: DictionaryInformations) => {
                return { name: dictionary.title, value: dictionary.filename };
            });
        });
        this.isObjectivesMode = this.router.url.includes('log2990') ? true : false;
    }

    createGame(): void {
        if (this.gameType === GameType.MULTIPLAYER) {
            this.createRoom();
        } else {
            const gameMode = this.router.url.includes('log2990') ? GameMode.LOG2990 : GameMode.CLASSIC;
            this.gameService.setId(this.socketManagerService.getId());
            this.gameService.setPlayer(this.authService.userProfile.userName!);
            this.gameService.setTimerDuration(this.timer);
            this.socketManagerService.emit(
                GAME_CREATE_SOLO,
                this.authService.userProfile.userName!,
                { timer: this.timer, dictionary: this.dictionary, mode: gameMode, visibility: this.visibility },
                this.level,
            );

            const query = this.router.url.includes('log2990') ? 'log2990' : 'classic';
            this.router.navigate([GAME_PAGE_PATH], { queryParams: { mode: query } });
        }
        this.musicService.playMusic();
    }

    createRoom(): void {
        const gameMode = this.router.url.includes('log2990') ? GameMode.LOG2990 : GameMode.CLASSIC;
        this.roomService.createRoom(this.authService.userProfile.userName!, {
            timer: this.timer,
            dictionary: this.dictionary,
            mode: gameMode,
            visibility: this.visibility,
            password: this.paramsForm.value.password,
        });
        this.router.navigate([this.backLink + 'waiting'], { queryParams: { visibility: this.visibility } });
    }

    confirm(): void {
        this.confirmed = true;
    }

    showPassword() {
        this.show = !this.show;
    }
}
