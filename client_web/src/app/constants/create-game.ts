import { GameVisibility } from '@app/classes/game/game-visibility';
import { VirtualPlayerLevel } from '@app/classes/virtual-player/virtual-player-level';

export const NAME_MAX_LENGTH = 16;
export const PASSWORD_MAX_LENGTH = 10;
export const NAME_PATTERN = '[a-zA-Z ]*';
export const MAIL_ADDRESS_PATTERN = '^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,4}$';
export const TIMER_OPTIONS = [
    { name: '30s', value: 30 },
    { name: '1min', value: 60 },
    { name: '1min30s', value: 90 },
    { name: '2min', value: 120 },
    { name: '2min30s', value: 150 },
    { name: '3min', value: 180 },
    { name: '3min30s', value: 210 },
    { name: '4min', value: 240 },
    { name: '4min30s', value: 270 },
    { name: '5min', value: 300 },
];
export const VISIBILITY_OPTIONS = [
    { name: 'Privée', value: GameVisibility.PRIVATE },
    { name: 'Publique', value: GameVisibility.PUBLIC },
];
export const VISIBILITY_DEFAULT = VISIBILITY_OPTIONS[0].value;
export const TIMER_DEFAULT = TIMER_OPTIONS[1].value;
export const LEVEL_OPTIONS = [
    { name: 'Débutant', value: VirtualPlayerLevel.BEGINNER },
    { name: 'Expert', value: VirtualPlayerLevel.EXPERT },
];
export const LEVEL_DEFAULT = LEVEL_OPTIONS[0].value;
export const MESSAGE_ABORTED = "Cette partie n'existe plus, veuillez en sélectionner une autre.";
export const MESSAGE_REJECTED = "L'hôte de la partie a rejeté votre demande, veuillez sélectionner une autre partie.";
export const MESSAGE_ACCEPTED = "L'hôte de la partie a accepté votre demande, veuillez patienter pour que l'hôte démarre la partie.";
