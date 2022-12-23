import { Component } from '@angular/core';
import { MusicService } from '@app/services/music/music.service';

@Component({
    selector: 'app-multiplayer-page',
    templateUrl: './multiplayer-page.component.html',
    styleUrls: ['./multiplayer-page.component.scss'],
})
export class MultiplayerPageComponent {
    constructor(public readonly musicService: MusicService) {}
}
