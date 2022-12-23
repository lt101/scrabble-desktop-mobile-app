import { DataPersistence, Language, VisualTheme } from '@app/classes/data-persistence/data-persistence';
import { DATABASE_COLLECTION } from '@app/constants/data-persistence';
import { DatabaseService } from '@app/database/database/database.service';
import { Collection } from 'mongodb';
import 'reflect-metadata';
import { Service } from 'typedi';
@Service()
export class DataPersistenceService {
    constructor(private databaseService: DatabaseService) {}
    get collection(): Collection<DataPersistence> {
        return this.databaseService.database.collection(DATABASE_COLLECTION);
    }

    async createDataPersistence(emailAddress: string): Promise<void> {
        const dataPersistence = {
            emailAddress,
            language: Language.FR,
            visualTheme: VisualTheme.Light,
        };
        await this.collection.insertOne(dataPersistence);
    }

    async getDataPersistence(emailAddress: string): Promise<DataPersistence[]> {
        return this.collection
            .find({ emailAddress })
            .toArray()
            .then((dataPersistence: DataPersistence[]) => {
                return dataPersistence;
            });
    }

    async updateLanguage(emailAddress: string, language: string): Promise<void> {
        await this.collection.updateOne({ emailAddress }, { $set: { language } }).then();
    }

    async updateVisualTheme(emailAddress: string, visualTheme: string): Promise<void> {
        await this.collection.updateOne({ emailAddress }, { $set: { visualTheme } }).then();
    }
}
