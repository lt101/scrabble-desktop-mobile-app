import { ConnectionHistory } from '@app/classes/connection-history/connection-history';
import { DATABASE_COLLECTION } from '@app/constants/connection-history';
import { DatabaseService } from '@app/database/database/database.service';
import { Collection } from 'mongodb';
import 'reflect-metadata';
import { Service } from 'typedi';
@Service()
export class ConnectionHistoryService {
    constructor(private databaseService: DatabaseService) {}

    get collection(): Collection<ConnectionHistory> {
        return this.databaseService.database.collection(DATABASE_COLLECTION);
    }

    async createConnectionHistory(emailAddress: string): Promise<void> {
        const connectionHistory = {
            emailAddress,
            connection: [],
        };
        await this.collection.insertOne(connectionHistory);
    }

    async getConnectionHistory(emailAddress: string): Promise<ConnectionHistory[]> {
        return this.collection
            .find({ emailAddress })
            .toArray()
            .then((connectionHistory: ConnectionHistory[]) => {
                return connectionHistory;
            });
    }

    async addLogConnection(emailAddress: string, logDate: string, status: string): Promise<void> {
        const connection = {
            logDate,
            status,
        };
        return this.collection.updateOne({ emailAddress }, { $push: { connection } }).then();
    }
}
