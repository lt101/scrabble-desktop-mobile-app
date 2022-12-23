import { GameStatus } from '@app/classes/game-played-history/game-played-history';
import { UserProfile } from '@app/classes/user-profile/user-profile';
import { GamePlayedHistoryService } from '@app/database/game-played-history/game-played-history';
import { UserProfileService } from '@app/database/user-profile/user-profile.service';
import 'reflect-metadata';
import { Service } from 'typedi';

@Service()
export class GamePlayedHistoryHandler {
    constructor(private gamePlayedHistoryService: GamePlayedHistoryService, private userProfileService: UserProfileService) {}

    // Cette methode doit etre appeler lors de la creatiion d'un compte utilisateur
    async initializeGamePlayedHistory(emailAddress: string): Promise<void> {
        await this.gamePlayedHistoryService.createGamePlayedHistory(emailAddress);
    }
    async getAllGameStatus(emailAddress: string): Promise<GameStatus[]> {
        const gamePlayedHistory = await this.gamePlayedHistoryService.getGamePlayedHistory(emailAddress);
        return gamePlayedHistory[0].gameStatus;
    }
    async addGamePlayed(userName: string, startDate: Date, endDate: Date, isWinner: boolean): Promise<void> {
        console.log("addGamePlayed call")
        const userProfile: UserProfile[] = await this.userProfileService.getUserProfileByUsername(userName);
        const emailAddress: string = userProfile[0].emailAddress as string;
        await this.gamePlayedHistoryService.addGamePlayed(emailAddress, startDate, endDate, isWinner);
    }
}
