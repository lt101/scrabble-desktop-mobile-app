import { Letter } from '@app/classes/common/letter';
import { Duration } from '@app/classes/game-history/duration';
import { GameParameters } from '@app/classes/game/game-parameters';
import { GameType } from '@app/classes/game/game-type';
import { GridServer } from '@app/classes/grid/grid';
import { Objective } from '@app/classes/objective/objective';
import { Player } from '@app/classes/player/player';
import { PlayerInformations } from '@app/classes/player/player-informations';
import { Reserve } from '@app/classes/reserve/reserve';
import { SidebarInformations } from '@app/classes/sidebar/sidebar-informations';
import { VirtualPlayerLevel } from '@app/classes/virtual-player/virtual-player-level';
import { EASEL_MAX_SIZE } from '@app/constants/easel';
import { END_GAME_TURN_THRESHOLD, MILLISECONDS_TO_SECONDS_FACTOR, SECONDS_TO_MINUTES_FACTOR } from '@app/constants/game';
import { UserProfileHandler } from '@app/services/user-profile/user-profile-handler';
import { UserProfile } from '../user-profile/user-profile';
import { VirtualPlayer } from '../virtual-player/virtual-player';

export class Game {
    id: string;
    parameters: GameParameters;
    grid: GridServer;
    reserve: Reserve;
    currentPlayer: Player;
    players: Player[] = [];
    observers: Player[] = [];
    type: GameType;
    isGridEmpty: boolean;
    objectives: Objective[] = [];
    isPrivateSet: boolean = false;
    allPlacedWords: string[] = [];
    start: Date;
    startTurn: Date;
    newVirtualPlayer: PlayerInformations;
    newPlayerFromObserver: PlayerInformations;
    constructor(hostInformations: PlayerInformations, parameters: GameParameters, type: GameType, private userProfileHandler: UserProfileHandler) {
        this.id = hostInformations.id;
        this.start = new Date();
        this.parameters = parameters;
        this.reserve = new Reserve();
        this.grid = new GridServer();
        this.isGridEmpty = true;
        this.type = type;
        this.startTurn = new Date();
    }

    /**
     * Termine la partie
     *
     * @returns Durée de la partie
     */
    end(): Duration {
        const delta = Math.ceil((new Date().getTime() - this.start.getTime()) / MILLISECONDS_TO_SECONDS_FACTOR);
        const seconds = delta % SECONDS_TO_MINUTES_FACTOR;
        const minutes = (delta - seconds) / SECONDS_TO_MINUTES_FACTOR;
        return { seconds, minutes };
    }

    /**
     * Créé et assigne les joueurs de la partie
     *
     * @param host Informations du joueur hôte
     * @param guest Informations du joueur invité
     */
    setPlayersMultiplayer(host: PlayerInformations, guests: PlayerInformations[]): void {
        this.players.push(new Player(host.name, host.id, this.reserve.removeRandomLetters(EASEL_MAX_SIZE)));
        guests.forEach((guest) => {
            if (guest.id.includes('virtual')) {
                this.players.push(
                    new VirtualPlayer(guest.name, guest.id, this.reserve.removeRandomLetters(EASEL_MAX_SIZE), VirtualPlayerLevel.BEGINNER),
                );
            } else {
                this.players.push(new Player(guest.name, guest.id, this.reserve.removeRandomLetters(EASEL_MAX_SIZE)));
            }
        });

        do this.currentPlayer = this.players[Math.floor(Math.random() * this.players.length)];
        while (this.currentPlayer.getId().includes('virtual'));
    }

    setObjectives(objectives: Objective[]): void {
        this.objectives = objectives;
    }

    /**
     * Indique si c'est à ce joueur de jouer
     *
     * @param playerId Identifiant du joueur
     * @returns Booléen qui indique si c'est à ce joueur de jouer
     */
    isThisPlayerTurn(playerId: string): boolean {
        return this.currentPlayer.getId() === playerId;
    }

    /**
     * Vérifie si les deux joueurs ont passé leur tour 3 fois de suite
     *
     * @returns Booléen qui indique si la partie est terminée
     */
    checkForEndGameAfterTakeTurn(): boolean {
        let counter = 0;

        this.players.forEach((player) => {
            if (player.passedTurn >= END_GAME_TURN_THRESHOLD) counter++;
        });

        if (counter === this.players.length) return true;
        return false;
    }

    /**
     * Vérifie si la réserve est vide et le chevalet du joueur courant aussi
     *
     * @returns Booléen qui indique si la partie est terminée
     */
    checkForEmptyReserveAndEasel(): boolean {
        if (this.reserve.isEmpty() && this.currentPlayer.getEasel().isEmpty()) {
            this.currentPlayer.addScore(this.getPointsFromOthers());
            return true;
        }

        return false;
    }

    /**
     * Retourne Le score correpondant aux lettres restantes des chevalets des autres joueurs
     *
     * @returns Le score correpondant aux lettres restantes des chevalets des autres joueurs
     */
    getPointsFromOthers(): number {
        let easelScore = 0;
        this.players.forEach((player) => {
            easelScore += player.getEasel().getScore();
        });
        return easelScore;
    }

    /**
     * Augmente le score du joueur courant
     *
     * @param score Score à ajouter
     */
    addScore(score: number): void {
        this.currentPlayer.addScore(score);
    }

    /**
     * Augmente le score du joueur par rapport aux objectifs accomplis
     *
     * @param objectives Liste des objectifs de la partie
     */
    addScoreObjective(objectives: Objective[]) {
        for (const objective of objectives) {
            if (objective.checked && !objective.done) {
                this.currentPlayer.addScore(objective.points);
                objective.done = true;
            }
        }
    }

    /**
     * Passe le tour du joueur (c'est à l'autre joueur de jouer)
     *
     * @param byCommand Booléen qui indique si l'action est prise par une commande
     */
    takeTurn(byCommand: boolean): void {
        this.currentPlayer.passedTurn = byCommand ? ++this.currentPlayer.passedTurn : 0;
        this.currentPlayer = this.getNextPlayer();
        this.startTurn = new Date();
    }

    /**
     * Retourne le message de fin de partie
     *
     * @returns Message de fin de partie
     */
    getEndMessage(): string {
        let message = `Fin de partie - ${this.reserve.getSize()} lettres restantes\n`;
        this.players.forEach((player) => {
            message += `${player.getName()}: ${player
                .getEasel()
                .getContent()
                .map((l) => l.letter)
                .join('')}\n`;
        });
        return message;
    }

    /**
     * Échange des lettres entre le chevalet du joueur courant et la réserve
     *
     * @param letters Lettres à échanger
     * @param putBackInReserve Booléen qui indique s'il faut remettre les lettres dans la réserve
     */
    exchange(letters: Letter[], putBackInReserve: boolean): void {
        const easel = this.currentPlayer.getEasel();
        if (easel.containsLetters(letters)) {
            easel.removeLetters(letters);
            if (putBackInReserve) this.reserve.addLetters(letters);
            easel.addLetters(this.reserve.removeRandomLetters(letters.length));
        }
    }
    async getUserStatSideBarByUsername(): Promise<UserProfile[]> {
        const usernames: string[] = [];
        this.players.forEach((player) => {
            usernames.push(player.getName());
        });
        console.log('usernames are:');
        console.log(usernames);
        let a = await this.userProfileHandler.getSidebarUserStats(usernames);
        console.log('print des a');
        console.log(a[0]);
        console.log(a[1]);
        console.log(a[2]);
        console.log(a[3]);
        return a;
    }

    /**
     * Retourne les informations de la barre latérale
     *
     * @returns Informations de la barre latérale
     */
    getSidebarInformations(isObserver: boolean): SidebarInformations {
        const playersInfo: { playerId: string; playerName: string; score: number; easelSize: number }[] = [];
        this.players.forEach((player) => {
            playersInfo.push({
                playerId: player.getId(),
                playerName: player.getName(),
                score: player.getScore(),
                easelSize: player.getEasel().getSize(),
            });
        });
        return {
            reserveSize: this.reserve.getSize(),
            currentPlayerId: this.currentPlayer.getId(),
            players: playersInfo,
            isObserver,
        };
    }

    /**
     * Retourne le prochain joueur
     *
     * @returns Informations du prochain joueur
     */
    getNextPlayer(): Player {
        const index = (this.players.indexOf(this.currentPlayer) + 1) % this.players.length;
        return this.players[index];
    }
}
