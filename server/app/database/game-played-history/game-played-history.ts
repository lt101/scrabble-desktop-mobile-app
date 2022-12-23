import { GamePlayedHistory } from '@app/classes/game-played-history/game-played-history';
import { DATABASE_COLLECTION } from '@app/constants/game-played-history';
import { DatabaseService } from '@app/database/database/database.service';
import { Collection } from 'mongodb';
import 'reflect-metadata';
import { Service } from 'typedi';
@Service()

export class GamePlayedHistoryService {
    constructor(private databaseService: DatabaseService) {}

    get collection(): Collection<GamePlayedHistory> {
        return this.databaseService.database.collection(DATABASE_COLLECTION);
    }

    async createGamePlayedHistory(emailAddress: string): Promise<void> {
        let gamePlayedHistory = 
        {
            emailAddress: emailAddress,
            gameStatus: [],
        }
        await this.collection.insertOne(gamePlayedHistory);
    }

    async getGamePlayedHistory(emailAddress: string): Promise<GamePlayedHistory[]> {
        return this.collection
            .find({ emailAddress: emailAddress})
            .toArray()
            .then((gamePlayedHistory: GamePlayedHistory[]) => {
                return gamePlayedHistory;
            });
    }

    async addGamePlayed(emailAddress: string, startDate: Date, endDate: Date, isWinner: boolean): Promise<void> {
        let gameStatus = {
            startDate: startDate,
            endDate: endDate,
            isWinner: isWinner,
        }
        return this.collection.updateOne({emailAddress:emailAddress}, {$push: {gameStatus: gameStatus}}).then();
    }


}