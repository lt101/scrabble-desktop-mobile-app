import { DataPersistence } from '@app/classes/data-persistence/data-persistence';
import { DataPersistenceService } from '@app/database/data-persistence/data-persistence.service';
import 'reflect-metadata';
import { Service } from 'typedi';

@Service()
export class DataPersistenceHandler {
    constructor(private dataPersistenceService: DataPersistenceService) {}

    async initializeDataPersistence(emailAddress: string): Promise<void> {
        await this.dataPersistenceService.createDataPersistence(emailAddress);
    }

    async getDataPersistence(emailAddress: string): Promise<DataPersistence> {
        const dataPersistence = await this.dataPersistenceService.getDataPersistence(emailAddress);
        return dataPersistence[0];
    }

    async updateLanguage(emailAddress: string, language: string): Promise<void> {
        await this.dataPersistenceService.updateLanguage(emailAddress, language);
    }

    async updateVisualTheme(emailAddress: string, visualTheme: string): Promise<void> {
        await this.dataPersistenceService.updateVisualTheme(emailAddress, visualTheme);
    }
}
