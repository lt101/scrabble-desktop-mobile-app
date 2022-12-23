import { Injectable } from '@angular/core';
import { Letter } from '@app/classes/common/letter';
import { COMMAND_TAKE_TURN } from '@app/constants/command';
import { ChatboxService } from '@app/services/chatbox/chatbox.service';
import { GameService } from '@app/services/game/game.service';
import { Observable } from 'rxjs';
import { GridManagerService } from '../grid/grid-manager/grid-manager.service';

@Injectable({
    providedIn: 'root',
})
export class PassTurnService {
    constructor(
        private readonly chatboxService: ChatboxService,
        private readonly gameService: GameService,
        private gridManagerService: GridManagerService,
    ) {}

    /**
     * Retourne un observable qui indique si on est le joueur courant
     *
     * @returns Observable sur le joueur courant
     */
    isCurrentPlayer(): Observable<boolean> {
        return this.gameService.getCurrentPlayerObservable();
    }

    /**
     * Passe le tour du joueur
     */
    passTurn(): void {
        this.chatboxService.emitMessage(COMMAND_TAKE_TURN);
        this.gridManagerService.allCases = new Array<Letter>(225).fill({ letter: '', point: 106 }).map((_) => _);
    }
}
