import { Game } from '@app/classes/game/game';
import { Player } from '@app/classes/player/player';
import { CHATBOX_EVENT, SERVER_ID } from '@app/constants/chatbox';
import {
    EVENT_EASEL_UPDATED,
    EVENT_GAME_ENDED,
    EVENT_GRID_UPDATED,
    EVENT_OBJECTIVES_UPDATED,
    EVENT_PLAYER_STAT_SIDEBAR_UPDATED,
    EVENT_SIDEBAR_UPDATED,
    SURRENDER_MESSAGE,
} from '@app/constants/game';
import {
    OBJECTIVES_1,
    OBJECTIVES_2,
    OBJECTIVES_3,
    OBJECTIVES_4,
    OBJECTIVES_5,
    OBJECTIVES_6,
    OBJECTIVES_7,
    OBJECTIVES_8,
} from '@app/constants/objectives';
import { ObjectivesService } from '@app/services/objectives/objectives.service';
import { SocketCommunicationService } from '@app/services/socket-communication/socket-communication.service';
import { Service } from 'typedi';

@Service()
export class UpdateService {
    constructor(private readonly socketCommunicationService: SocketCommunicationService, private readonly objectivesService: ObjectivesService) {}
    /**
     * Met à jour les clients
     *
     * @param game Partie à mettre à jour
     */
    updateClient(game: Game, socketId: string, isObserver: boolean): void {
        this.updateGrid(game);
        this.updateEasel(game);
        this.updateSidebar(game, socketId, isObserver);
        game.observers.forEach((obs) => {
            this.updateSidebar(game, obs.getId(), true);
        });
    }

    /**
     * Met à jour les objectifs
     *
     * @param game Partie à mettre à jour
     */
    updateObjectives(game: Game): void {
        this.socketCommunicationService.emitToRoom(game.id, EVENT_OBJECTIVES_UPDATED, game.objectives);
    }

    /**
     * Met à jour le statut des objectifs
     *
     * @param game Partie à mettre à jour
     * @param placedWords Mots placés
     */
    updateObjectivesEachTurn(game: Game, placedWords: string[]): void {
        for (const objective of game.objectives) {
            switch (objective.code) {
                case OBJECTIVES_1:
                    objective.checked = this.objectivesService.wordContainsFourVowels(placedWords);
                    break;
                case OBJECTIVES_2:
                    objective.checked = this.objectivesService.hundredPointsWithoutExchangeOrHint(
                        game.currentPlayer.getScore(),
                        game.currentPlayer.usedExchange,
                    );
                    break;
                case OBJECTIVES_3:
                    objective.checked = this.objectivesService.placementLessFiveSeconds(new Date().getSeconds() - game.startTurn.getSeconds());
                    break;

                case OBJECTIVES_4:
                    objective.checked = this.objectivesService.wordIsPalindrome(placedWords);
                    break;
                case OBJECTIVES_5:
                    objective.checked = this.objectivesService.wordContainsNoConsonants(placedWords);
                    break;
                case OBJECTIVES_6:
                    objective.checked = this.objectivesService.wordBeginsAndEndsWithVowel(placedWords);
                    break;
                case OBJECTIVES_7:
                    objective.checked = this.objectivesService.positionO15Filled(game.grid.boxes);
                    break;
                case OBJECTIVES_8:
                    objective.checked = this.objectivesService.wordIsAnagram(placedWords, game.allPlacedWords);
                    break;
            }
        }
    }

    /**
     * Informe l'autre joueur qu'un joueur a abandonné la partie
     *
     * @param game Partie à mettre à jour
     * @param playerId Identifiant du joueur qui a abandonné
     */
    updateAfterSurrender(game: Game, surrenderName: string): void {
        this.socketCommunicationService.emitToRoom(game.id, CHATBOX_EVENT, {
            gameId: game.id,
            playerId: SERVER_ID,
            playerName: surrenderName,
            content: SURRENDER_MESSAGE,
        });
    }

    /**
     * Met à jour les scores en fin de partie
     *
     * @param game Partie à mettre à jour
     */
    updateEndScores(game: Game): void {
        const playersEndInfo: unknown[] = [];
        let winner: Player;
        if (game.players.length > 0) winner = game.players[0];
        game.players.forEach((player) => {
            playersEndInfo.push({
                player: { id: player.getId(), name: player.getName() },
                score: player.getScore(),
            });
            if (winner.getScore() < player.getScore()) winner = player;
        });
        this.socketCommunicationService.emitToRoom(game.id, EVENT_GAME_ENDED, playersEndInfo, winner!.getName());
    }

    /**
     * Met à jour les chevalets
     *
     * @param game Partie à mettre à jour
     */
    private updateEasel(game: Game): void {
        game.players.forEach((player) => {
            this.socketCommunicationService.emitToSocket(player.getId(), EVENT_EASEL_UPDATED, player.getEasel().getContent());
        });
    }

    /**
     * Met à jour la grille
     *
     * @param game Partie à mettre à jour
     */
    updateGrid(game: Game): void {
        this.socketCommunicationService.emitToRoom(game.id, EVENT_GRID_UPDATED, game.grid);
    }

    /**
     * Met à jour la barre latérale
     *
     * @param game Partie à mettre à jour
     */
    private async updateSidebar(game: Game, socketId: string, isObserver: boolean): Promise<void> {
        if (isObserver) {
            this.socketCommunicationService.emitToSocket(socketId, EVENT_SIDEBAR_UPDATED, game.getSidebarInformations(isObserver));
        } else {
            this.socketCommunicationService.emitToRoom(game.id, EVENT_SIDEBAR_UPDATED, game.getSidebarInformations(false));
            this.socketCommunicationService.emitToRoom(game.id, EVENT_PLAYER_STAT_SIDEBAR_UPDATED, await game.getUserStatSideBarByUsername());
        }
    }
}
