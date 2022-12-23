import { Connection } from '@app/classes/connection-history/connection-history';
import { ConnectionHistoryService } from '@app/database/connection-history/connection-history.service';
import 'reflect-metadata';
import { Service } from 'typedi';

@Service()
export class ConnectionHistoryHandler {
    constructor(private connectionHistoryService: ConnectionHistoryService) {}

    // Cette methode doit etre appeler lors de la creatiion d'un compte utilisateur
    async initializeConnectionHistory(emailAddress: string): Promise<void> {
        await this.connectionHistoryService.createConnectionHistory(emailAddress);
    }
    async getAllConnectionHistory(emailAddress: string): Promise<Connection[]> {
        const connectionHistory = await this.connectionHistoryService.getConnectionHistory(emailAddress);
        return connectionHistory[0].connection;
    }

    async addLogConnection(emailAddress: string, logDate: string, status: string): Promise<void> {
        await this.connectionHistoryService.addLogConnection(emailAddress, logDate, status);
    }
}
