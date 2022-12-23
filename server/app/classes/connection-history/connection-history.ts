export interface ConnectionHistory {
    emailAddress: string;
    connection: Connection[];
}

export interface Connection {
    logDate?: string;
    status?: string;
}

export enum Status {
    login = 'login',
    logout = 'logout',
}
