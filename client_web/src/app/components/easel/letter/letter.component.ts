import { Component, Input } from '@angular/core';
import { Letter } from '@app/classes/common/letter';
import { COLORS } from '@app/constants/easel';
import { EaselService } from '@app/services/easel/easel/easel.service';
import { GameService } from '@app/services/game/game.service';

@Component({
    selector: 'app-letter',
    templateUrl: './letter.component.html',
    styleUrls: ['./letter.component.scss'],
})
export class LetterComponent {
    @Input() card: Letter;
    @Input() index: number;
    borderColor: string;
    isPlaying: boolean;
    constructor(private readonly easelService: EaselService, private readonly gameService: GameService) {
        this.easelService.getSelection().subscribe(this.updateBorderColor.bind(this));
        this.gameService.getCurrentPlayerObservable().subscribe((value) => {
            this.isPlaying = value;
        });
    }

    isSelectionCard(): boolean {
        return this.easelService.isSelectionCard(this.card, this.index);
    }

    isExchangeCard(): boolean {
        return this.easelService.exchangeHasCard(this.card);
    }

    handleLeftClick(): void {
        if (!this.isExchangeCard() && this.isPlaying) {
            this.easelService.removeSelection();
            this.easelService.removeExchangeCard(this.card);
            this.easelService.makeSelection(this.card, this.index);
            this.updateBorderColor();
        }
    }

    handleRightClick(): void {
        if (this.isPlaying) {
            if (this.isExchangeCard()) {
                this.easelService.removeExchangeCard(this.card);
            } else {
                this.easelService.removeSelection();
                this.easelService.addExchangeCard(this.card);
            }

            this.updateBorderColor();
        }
    }

    updateBorderColor(): void {
        if (this.isSelectionCard()) {
            this.borderColor = COLORS.selection;
            return;
        }
        if (this.isExchangeCard()) {
            this.borderColor = COLORS.exchange;
            return;
        }
        this.borderColor = COLORS.black;
    }
}
