import { Injectable } from '@angular/core';

@Injectable({
    providedIn: 'root',
})
export class MusicService {
    audio = new Audio();
    effectAudio = new Audio();
    pause = true;
    musicIndex: number = 0;
    musicList: Array<string> = ['./assets/game-song.mp3'];
    constructor() {}
    playMusic(): void {
        if (this.musicIndex < this.musicList.length) {
            this.audio.src = this.musicList[this.musicIndex++];
        } else {
            this.musicIndex = 0;
            this.audio.src = this.musicList[this.musicIndex++];
        }
        this.audio.load();
        this.audio.play();
        this.audio.onended = () => {
            this.audio.onended = null;
            this.playMusic();
        };
    }
    pauseMusic(): void {
        if (this.pause) {
            this.audio.pause();
            this.pause = false;
        } else {
            this.audio.play();
            this.pause = true;
        }
    }
    playWordMusic(): void {
        this.effectAudio.src = './assets/word.wav';
        this.effectAudio.load();
        this.effectAudio.play();
    }
}
