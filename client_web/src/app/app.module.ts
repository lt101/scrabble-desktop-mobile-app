import { DragDropModule } from '@angular/cdk/drag-drop';
import { PortalModule } from '@angular/cdk/portal';
import { HttpClientModule } from '@angular/common/http';
import { NgModule } from '@angular/core';
import { initializeApp, provideFirebaseApp } from '@angular/fire/app';
import { getAuth, provideAuth } from '@angular/fire/auth';
import { getDatabase, provideDatabase } from '@angular/fire/database';
import { getFirestore, provideFirestore } from '@angular/fire/firestore';
import { getStorage, provideStorage } from '@angular/fire/storage';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { AdminDictionaryDeleteComponent } from '@app/components/admin-page/admin-dictionary-delete/admin-dictionary-delete.component';
import { AdminDictionaryEditComponent } from '@app/components/admin-page/admin-dictionary-edit/admin-dictionary-edit.component';
import { AdminDictionaryResetComponent } from '@app/components/admin-page/admin-dictionary-reset/admin-dictionary-reset.component';
import { AdminDictionaryComponent } from '@app/components/admin-page/admin-dictionary/admin-dictionary.component';
import { AdminGameHistoryComponent } from '@app/components/admin-page/admin-game-history/admin-game-history.component';
import { AdminVirtualPlayerDeleteComponent } from '@app/components/admin-page/admin-virtual-player-delete/admin-virtual-player-delete.component';
import { AdminVirtualPlayerEditComponent } from '@app/components/admin-page/admin-virtual-player-edit/admin-virtual-player-edit.component';
import { AdminVirtualPlayerComponent } from '@app/components/admin-page/admin-virtual-player/admin-virtual-player.component';
import { BestScoresClassiqueComponent } from '@app/components/best-scores/best-scores-classique/best-scores-classique.component';
import { BestScoresLOG2990Component } from '@app/components/best-scores/best-scores-log2990/best-scores-log2990.component';
import { CancelButtonComponent } from '@app/components/buttons/cancel-button/cancel-button.component';
import { ExchangeButtonComponent } from '@app/components/buttons/exchange-button/exchange-button.component';
import { PlayButtonComponent } from '@app/components/buttons/play-button/play-button.component';
import { ChatboxInputComponent } from '@app/components/chatbox/chatbox-input/chatbox-input.component';
import { ChatboxMessageComponent } from '@app/components/chatbox/chatbox-message/chatbox-message.component';
import { ChatboxMessagesComponent } from '@app/components/chatbox/chatbox-messages/chatbox-messages.component';
import { ChatboxComponent } from '@app/components/chatbox/chatbox/chatbox.component';
import { ControlPanelComponent } from '@app/components/control-panel/control-panel.component';
import { CreateGameComponent } from '@app/components/create-game/create-game.component';
import { EaselComponent } from '@app/components/easel/easel.component';
import { LetterComponent } from '@app/components/easel/letter/letter.component';
import { EndGameDialogComponent } from '@app/components/end-game-dialog/end-game-dialog.component';
import { EndGameComponent } from '@app/components/end-game/end-game.component';
import { PassButtonComponent } from '@app/components/pass-button/pass-button.component';
import { PlayAreaComponent } from '@app/components/play-area/play-area.component';
import { SidebarComponent } from '@app/components/sidebar/sidebar.component';
import { SurrenderButtonComponent } from '@app/components/surrender/surrender-button/surrender-button.component';
import { SurrenderDialogComponent } from '@app/components/surrender/surrender-dialog/surrender-dialog.component';
import { AppRoutingModule } from '@app/modules/app-routing.module';
import { AppMaterialModule } from '@app/modules/material.module';
import { AppComponent } from '@app/pages/app/app.component';
import { ClassicPageComponent } from '@app/pages/classic-page/classic-page.component';
import { GamePageComponent } from '@app/pages/game-page/game-page.component';
import { HighScoresPageComponent } from '@app/pages/high-scores-page/high-scores-page.component';
import { Log2990PageComponent } from '@app/pages/log2990-page/log2990-page.component';
import { LoginPageComponentComponent } from '@app/pages/login-page/login-page-component/login-page-component.component';
import {
    EditAvatarDialog,
    EditUsernameDialog,
    GamePlayedHistoryDialog,
    LoginHistoryDialog,
    MainPageComponent,
} from '@app/pages/main-page/main-page.component';
import { MaterialPageComponent } from '@app/pages/material-page/material-page.component';
import { MultiplayerCreatePageComponent } from '@app/pages/multiplayer-create-page/multiplayer-create-page.component';
import { MultiplayerJoinPageComponent } from '@app/pages/multiplayer-join-page/multiplayer-join-page.component';
import { MultiplayerPageComponent } from '@app/pages/multiplayer-page/multiplayer-page.component';
import { MultiplayerWaitingPageComponent } from '@app/pages/multiplayer-waiting-page/multiplayer-waiting-page.component';
import { RegisterPageComponentComponent } from '@app/pages/register-page/register-page-component/register-page-component.component';
import { SoloCreatePageComponent } from '@app/pages/solo-create-page/solo-create-page.component';
import { PickerModule } from '@ctrl/ngx-emoji-mart';
import { environment } from '../environments/environment';
import { AdminBestScoresComponent } from './components/admin-page/admin-best-scores/admin-best-scores/admin-best-scores.component';
import { ChatButtonComponent } from './components/chatbox/chat-button/chat-button.component';
import { ClueButtonComponent } from './components/clue/clue-button/clue-button.component';
import { ClueDialogComponent } from './components/clue/clue-dialog/clue-dialog.component';
import { LanguageSelectorComponentComponent } from './components/language-selector/language-selector-component/language-selector-component.component';
import { ObjectivesComponent } from './components/objectives/objectives/objectives.component';
import { FilterPipe } from './components/search/filter.pipe';
import { ThemeSwitcherComponent } from './components/theme-switcher/theme-switcher.component';
import { AdminPageComponent } from './pages/admin-page/admin-page.component';
import { TranslocoRootModule } from './transloco-root.module';

import { GameSettingsDialogComponent } from './components/game-settings-dialog/game-settings-dialog/game-settings-dialog.component';
import { SearchButtonComponent } from './components/search/search-button/search-button.component';
import { SearchDialogComponent } from './components/search/search-dialog/search-dialog.component';
import { WindowComponent } from './components/window/window.component';
import { ChatPageComponent } from './pages/chat-page/chat-page.component';
import { ThemeService } from './services/theme/theme.service';
import { UploadAvatarDialogComponent } from './components/upload-avatar/upload-avatar-dialog/upload-avatar-dialog.component';
/**
 * Main module that is used in main.ts.
 * All automatically generated components will appear in this module.
 * Please do not move this module in the module folder.
 * Otherwise Angular Cli will not know in which module to put new component
 */
@NgModule({
    declarations: [
        AppComponent,
        ControlPanelComponent,
        GamePageComponent,
        MainPageComponent,
        MaterialPageComponent,
        PlayAreaComponent,
        SidebarComponent,
        MultiplayerPageComponent,
        MultiplayerCreatePageComponent,
        MultiplayerJoinPageComponent,
        MultiplayerWaitingPageComponent,
        ChatboxComponent,
        EaselComponent,
        ChatboxMessagesComponent,
        ChatboxMessageComponent,
        EaselComponent,
        LetterComponent,
        ChatboxInputComponent,
        ClassicPageComponent,
        PassButtonComponent,
        CreateGameComponent,
        SoloCreatePageComponent,
        Log2990PageComponent,
        HighScoresPageComponent,
        BestScoresClassiqueComponent,
        BestScoresLOG2990Component,
        SurrenderButtonComponent,
        SurrenderDialogComponent,
        EndGameComponent,
        EndGameDialogComponent,
        PlayButtonComponent,
        ExchangeButtonComponent,
        CancelButtonComponent,
        AdminPageComponent,
        AdminDictionaryComponent,
        AdminVirtualPlayerComponent,
        AdminGameHistoryComponent,
        AdminVirtualPlayerEditComponent,
        AdminVirtualPlayerDeleteComponent,
        AdminDictionaryEditComponent,
        AdminDictionaryDeleteComponent,
        ObjectivesComponent,
        AdminDictionaryResetComponent,
        AdminBestScoresComponent,
        ClueButtonComponent,
        ClueDialogComponent,
        SearchButtonComponent,
        SearchDialogComponent,
        EditUsernameDialog,
        EditAvatarDialog,
        LoginHistoryDialog,
        GamePlayedHistoryDialog,
        LoginPageComponentComponent,
        RegisterPageComponentComponent,
        FilterPipe,
        ThemeSwitcherComponent,
        LanguageSelectorComponentComponent,
        ChatButtonComponent,
        ChatPageComponent,
        WindowComponent,
        GameSettingsDialogComponent,
        UploadAvatarDialogComponent,
    ],
    imports: [
        AppMaterialModule,
        AppRoutingModule,
        BrowserAnimationsModule,
        BrowserModule,
        FormsModule,
        HttpClientModule,
        ReactiveFormsModule,
        BrowserAnimationsModule,
        PickerModule,

        provideFirebaseApp(() => initializeApp(environment.firebase)),
        provideAuth(() => getAuth()),
        provideDatabase(() => getDatabase()),
        provideFirestore(() => getFirestore()),
        provideStorage(() => getStorage()),
        DragDropModule,
        TranslocoRootModule,
        PortalModule,
    ],
    providers: [],
    bootstrap: [AppComponent],
    entryComponents: [WindowComponent],
})
export class AppModule {
    constructor(themeService: ThemeService) {
        if (!localStorage.getItem('language')) {
            localStorage.setItem('language', 'FR');
        }
    }

    // Dans le component

    getLanguage(): string {
        return localStorage.getItem('language') as string;
    }

    setLanguage(language: string) {
        localStorage.setItem('language', language);
    }
}
