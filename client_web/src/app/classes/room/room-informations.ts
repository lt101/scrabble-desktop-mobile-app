import { GameParameters } from '@app/classes/game/game-parameters';
import { PlayerInformations } from '@app/classes/player/player-informations';

export interface RoomInformations {
    id: string;
    hostName: string;
    parameters: GameParameters;
    players: PlayerInformations[];
    observers: PlayerInformations[];
}
