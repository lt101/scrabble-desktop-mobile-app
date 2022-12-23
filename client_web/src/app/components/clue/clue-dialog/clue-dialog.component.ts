import { Component, OnInit } from '@angular/core';
import { GameService } from '@app/services/game/game.service';
import { SocketManagerService } from '@app/services/socket-manager/socket-manager.service';

@Component({
    selector: 'app-clue-dialog',
    templateUrl: './clue-dialog.component.html',
    styleUrls: ['./clue-dialog.component.scss'],
})
export class ClueDialogComponent implements OnInit {
    isWaiting: boolean = true;
    hints: string[];

    constructor(private readonly socketManagerService: SocketManagerService, private readonly gameService: GameService) {}

    ngOnInit(): void {
        this.socketManagerService.emit('game:get_hints', this.gameService.getId());
        this.socketManagerService.on('game:return_hints', (hints: string) => {
            this.hints = (hints + '!').split('placer').join('').split('!');

            for (let i = 0; i < this.hints.length; i++) {
                const h = this.hints[i].match(/[a-z]+|[^a-z]+/g);
                if (h)
                    this.hints[i] =
                        'Position: ' +
                        h[1] +
                        h[2] +
                        ' | Orientation: ' +
                        h[3].replace('v', 'Vertical').replace('h', 'Horizontal') +
                        ' | Lettres: ' +
                        h[5];
            }

            if (hints.length !== 0) this.isWaiting = false;
        });
    }
}
