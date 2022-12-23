import { Component, OnInit } from '@angular/core';
import { GameService } from '@app/services/game/game.service';
import { SocketManagerService } from '@app/services/socket-manager/socket-manager.service';
import { TranslocoService } from '@ngneat/transloco';
import { FilterPipe } from '../filter.pipe';

@Component({
    selector: 'app-search-dialog',
    templateUrl: './search-dialog.component.html',
    styleUrls: ['./search-dialog.component.scss'],
})
export class SearchDialogComponent implements OnInit {
    words: string[] = [];
    searchedWord = '';
    placeHolder: string;
    filter: FilterPipe;
    constructor(
        private readonly socketManagerService: SocketManagerService,
        private readonly gameService: GameService,
        private readonly translocoService: TranslocoService,
    ) {}

    ngOnInit(): void {
        this.translocoService.selectTranslate('search.searchWord').subscribe((translation) => {
            this.placeHolder = translation;
        });
    }

    updateWords(newWord: string): void {
        if (newWord.length > 1) {
            this.socketManagerService.emit('game:get_dictionary', this.gameService.getId(), newWord);
            this.socketManagerService.on('game:return_dictionary', (dict: string[]) => {
                this.words = [...dict];
            });
        } else this.words = [];
    }
}
