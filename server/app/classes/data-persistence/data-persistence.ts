export interface DataPersistence {
    emailAddress: string;
    language: string;
    visualTheme: string;
}

export enum Language {
    FR = 'fr',
    EN = 'en',
}

export enum VisualTheme {
    Dark = 'dark',
    Light = 'light',
}
