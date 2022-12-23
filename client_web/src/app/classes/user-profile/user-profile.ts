import { Duration } from '../duration/duration';

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
