import { GameParameters } from '@app/classes/game/game-parameters';
import { PlayerInformations } from '@app/classes/player/player-informations';

export class Room {
    id: string;
    host: PlayerInformations;
    guests: PlayerInformations[] = [];
    observers: PlayerInformations[] = [];
    parameters: GameParameters;
    gameHasStarted: boolean = false;

    constructor(id: string, host: PlayerInformations, parameters: GameParameters) {
        this.id = id;
        this.host = host;
        this.parameters = parameters;
    }
    /**
     * Indique si la salle est pleine
     *
     * @returns Booléen qui indique si la salle est pleine
     */
    isFull(): boolean {
        let isFull = true;
        this.guests.forEach((guest) => {
            if (guest.id.includes('virtual')) isFull = false;
        });
        return isFull;
    }

    /**
     * Indique si la partie peut être commencée avec au moins 1 autre joueur humain
     *
     * @returns Booléen qui indique si la partie peut être commencée
     */
    canStart(): boolean {
        let canStart = false;
        this.guests.forEach((guest) => {
            if (!guest.id.includes('virtual')) canStart = true;
        });
        return canStart;
    }

    /**
     * Ajoute un joueur invité à la salle
     *
     * @param guest Information du joueur invité
     */
    addGuest(guest: PlayerInformations): void {
        this.guests.push(guest);
    }

    /**
     * Supprime le joueur invité de la salle
     */
    removeGuest(rejectedGuest: PlayerInformations): void {
        this.guests.splice(
            this.guests.findIndex((guest) => guest.id === rejectedGuest.id),
            1,
        );
    }

    /**
     * Supprime le joueur invité de la salle
     */
    removeAllGuests(): void {
        this.guests = undefined as unknown as PlayerInformations[];
    }
}
