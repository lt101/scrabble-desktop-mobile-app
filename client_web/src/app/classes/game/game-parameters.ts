import { GameMode } from '@app/classes/game/game-mode';
import { GameVisibility } from './game-visibility';

export interface GameParameters {
    timer: number;
    dictionary: string;
    mode: GameMode;
    visibility: GameVisibility;
    password: string;
}
