import { Duration } from '@app/classes/game-history/duration';

export interface UserProfile {
    emailAddress?: string;
    password?: string;
    userName?: string;
    isSigned?: boolean;
    avatarUrl?: string;
    grade?: string;
    level?: string;
    gamePlayed?: number;
    gameWon?: number;
    gameLost?: number;
    averagePoints?: number;
    averageTime?: Duration;
}

export enum Grade {
    NoGrade = "pas de grade",
    Bronze = "Bronze",
    Silver = "Silver",
    Gold = "Gold",
    Platinum = "Platinum",
    Diamond = "Diamond"
}

export enum Level {
    NoLevel = "pas de niveau",
    Novice = "Novice",
    Casual = "Casual",
    Pro = "Pro",
    Master = "Master",
}
