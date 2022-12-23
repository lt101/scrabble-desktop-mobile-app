export type Message = {
    gameId: string | null;
    playerId: string;
    playerName: string;
    content: string;
    cssClass?: string;
    time?: string;
};
