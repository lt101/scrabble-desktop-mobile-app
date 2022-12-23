export interface UserPreferences {
    emailAddress: string;
    language: string;
    visualTheme: string;
}

export enum Language {
    FR = 'French',
    EN = 'English',
}

export enum ColorScheme {
    Dark = 'dark',
    Light = 'light',
}
