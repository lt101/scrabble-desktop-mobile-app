export interface GamePlayedHistory {
    emailAddress: string;
    gameStatus: GameStatus[];

}

export interface GameStatus {
    startDate: Date;
    endDate: Date;
    isWinner: boolean;
}