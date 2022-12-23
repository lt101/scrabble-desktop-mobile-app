import { HttpResponse } from '@angular/common/http';
import { Component, Inject, OnInit } from '@angular/core';
import { MatDialog, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { Connection } from '@app/classes/connection/connection';
import { GameStatus } from '@app/classes/game-status/game-status';
import { UserProfile } from '@app/classes/user-profile/user-profile';
import { GameSettingsDialogComponent } from '@app/components/game-settings-dialog/game-settings-dialog/game-settings-dialog.component';
import { UploadAvatarDialogComponent } from '@app/components/upload-avatar/upload-avatar-dialog/upload-avatar-dialog.component';
import { AuthService } from '@app/services/authentication/auth-service.service';
import { ProfileService } from '@app/services/profile/profile.service';
import { TranslocoService } from '@ngneat/transloco';

export interface DialogData {
    name: string;
}

@Component({
    selector: 'app-main-page',
    templateUrl: './main-page.component.html',
    styleUrls: ['./main-page.component.scss'],
})
export class MainPageComponent implements OnInit {
    grade: string;
    level: string;
    constructor(
        public authService: AuthService,
        public dialog: MatDialog,
        public profileService: ProfileService,
        private router: Router,
        private readonly translocoService: TranslocoService,
    ) {}
    ngOnInit(): void {
        this.translocoService.selectTranslate(this.authService.userProfile.grade as string).subscribe((translation) => {
            this.grade = translation;
        });
        this.translocoService.selectTranslate(this.authService.userProfile.level as string).subscribe((translation) => {
            this.level = translation;
        });
    }
    readonly title: string = 'LOG2990';
    sidebarWidth: string = '0';

    name: string;

    signOut() {
        this.authService.signOut(this.authService.userProfile.emailAddress!).subscribe(
            (res) => {
                console.log(res);
                // this.themeService.set(ColorScheme.Light);
                if (localStorage.getItem('scheme') !== null) localStorage.removeItem('scheme');
                this.authService.isLoggedIn = false;
                this.authService.authStatus.next(false);
                this.authService.localStorageService.removeUserProfile();
                this.authService.logout();
                this.router.navigate(['/login']);
            },
            (err) => {
                console.log(err);
                // this.themeService.set(ColorScheme.Light);
                if (localStorage.getItem('scheme') !== null) localStorage.removeItem('scheme');
                this.authService.isLoggedIn = false;
                this.authService.authStatus.next(false);
                this.authService.localStorageService.removeUserProfile();
                this.authService.logout();
                this.router.navigate(['/login']);
            },
        );
    }

    openSideBar() {
        this.profileService.updateUserProfile(this.authService.userProfile.emailAddress!).subscribe((result) => {
            const newUserProfile = result.body as UserProfile[];
            this.authService.userProfile = newUserProfile[0];
            this.authService.localStorageService.storeUserProfile(this.authService.userProfile);
        });
        this.sidebarWidth = '25vw';
    }

    closeSideBar() {
        this.sidebarWidth = '0';
    }

    openUsernameDialog(): void {
        const dialogRef = this.dialog.open(EditUsernameDialog, {
            width: '250px',
            data: { name: this.name },
        });

        dialogRef.afterClosed().subscribe((result) => {
            console.log('The dialog was closed');
            this.name = result;
        });
    }

    openAvatarDialog() {
        const dialogRef = this.dialog.open(EditAvatarDialog, {
            height: '100%',
            width: '100%',
        });

        dialogRef.afterClosed().subscribe((result) => {
            console.log(`Dialog result: ${result}`);
        });
    }

    openLoginHistoryDialog() {
        const dialogRef = this.dialog.open(LoginHistoryDialog);

        dialogRef.afterClosed().subscribe((result) => {
            console.log(`Dialog result: ${result}`);
        });
    }

    openGamePlayedHistoryDialog() {
        const dialogRef = this.dialog.open(GamePlayedHistoryDialog);

        dialogRef.afterClosed().subscribe((result) => {
            console.log(`Dialog result: ${result}`);
        });
    }

    openGameSettingsDialog() {
        this.dialog.open(GameSettingsDialogComponent);
    }
}

@Component({
    selector: 'edit-username-dialog',
    templateUrl: './edit-username/edit-username-dialog.html',
    styleUrls: ['./edit-username/edit-username-dialog.scss'],
})
export class EditUsernameDialog {
    usernameError: string = '';
    constructor(
        public dialogRef: MatDialogRef<EditUsernameDialog>,
        @Inject(MAT_DIALOG_DATA) public data: DialogData,
        public profileService: ProfileService,
    ) {}

    onNoClick(): void {
        this.dialogRef.close();
    }

    changeUsername(newUsername: string) {
        if (newUsername.length != 0) {
            this.profileService.sendUsernameToServer(newUsername).subscribe(
                (response: HttpResponse<any>) => {
                    console.log(response);
                    this.profileService.authService.userProfile = response.body;
                    this.profileService.authService.localStorageService.storeUserProfile(this.profileService.authService.userProfile);
                    this.usernameError = '';
                    this.dialogRef.close();
                },
                (error) => {
                    switch (error.status) {
                        case 403:
                            this.usernameError = "Ce pseudonyme n'est pas disponible";
                            break;
                        default:
                            this.usernameError = 'Erreur inconnue';
                    }
                },
            );
        } else this.usernameError = 'Erreur, un champ requis est vide';
    }
}

@Component({
    selector: 'edit-avatar-dialog',
    templateUrl: './edit-avatar/edit-avatar-dialog.html',
    styleUrls: ['./edit-avatar/edit-avatar-dialog.scss'],
})
export class EditAvatarDialog {
    constructor(public profileService: ProfileService, public dialog: MatDialog) {}

    avatars: string[] = [
        'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_1.jpg?alt=media&token=5f5f4122-705b-43a2-885c-1e427a787190',
        'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_2.jpg?alt=media&token=034e39cb-91f4-4835-8239-171210151b94',
        'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_3.jpg?alt=media&token=036565d1-5702-43c8-bf24-a9f2c82c0c07',
        'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_4.jpg?alt=media&token=683738d0-6b24-41bd-9597-35a0f8d0bda2',
        'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_5.jpg?alt=media&token=8c020d2a-e6cd-4d73-9cf8-27ae146747c1',
        'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_6.jpg?alt=media&token=738255a0-fe3f-498c-9bd5-782483665a0f',
        'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_7.jpg?alt=media&token=ee93afa3-56e6-4764-9463-330f63ca01fb',
        'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_8.png?alt=media&token=3e306ae1-c8d9-47fd-8059-4d77fd3f9ef6',
        'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_9.jpg?alt=media&token=b7488b15-b5d7-46b8-b424-06fd7f88dada',
        'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_10.jpg?alt=media&token=7559a902-c99f-43a9-81d8-313e0fd297d5',
        'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_11.jpg?alt=media&token=33171d95-fcaa-40d2-8f54-2aaa0bc106a3',
        'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/avatars%2Fprofil_12.jpg?alt=media&token=1aa7fa80-f5c1-4adf-b457-673bbb82aec9',
    ];
    selectedAvatarIndex: number;
    setSelection(index: number): void {
        this.selectedAvatarIndex = index;
        console.log('set' + index);
    }
    changeAvatar() {
        if (this.selectedAvatarIndex != undefined) {
            this.profileService.sendAvatarToServer(this.avatars[this.selectedAvatarIndex]);
        }
    }

    openAvatarUploadDialog() {
        this.dialog.open(UploadAvatarDialogComponent);
    }
}

@Component({
    selector: 'login-history-dialog',
    templateUrl: './login-history/login-history-dialog.html',
    styleUrls: ['./login-history/login-history-dialog.scss'],
})
export class LoginHistoryDialog {
    loginHistory: Connection[];
    logins: string[] = [];
    logouts: string[] = [];
    logArr: Object[] = [];
    displayedColumns = ['index', 'login', 'logout'];
    constructor(public profileService: ProfileService) {
        this.profileService.authService
            .getConnectionHistory(this.profileService.authService.userProfile.emailAddress!)
            .subscribe((response: HttpResponse<Connection[]>) => {
                this.loginHistory = response.body as Connection[];
                this.getLogsArray();
            });
    }

    getLogsArray() {
        this.loginHistory.forEach((element) => {
            if (element.status === 'login') {
                this.logins.push(element.logDate!);
            } else this.logouts.push(element.logDate!);
        });
        let arr = [];
        for (let i = 0; i < Math.max(this.logins.length, this.logouts.length); i++) {
            let login = this.logins[i] != null ? this.logins[i] : '';
            let logout = this.logouts[i] != null ? this.logouts[i] : '';
            arr[i] = { loginDate: login, logoutDate: logout };
        }
        this.logArr = arr;
    }
}

@Component({
    selector: 'game-played-history-dialog',
    templateUrl: './game-played-history/game-played-history-dialog.html',
    styleUrls: ['./game-played-history/game-played-history-dialog.scss'],
})
export class GamePlayedHistoryDialog {
    gamePlayedHistory: GameStatus[] = [];
    displayedColumns = ['index', 'start', 'end', 'result'];
    constructor(public profileService: ProfileService) {
        this.profileService.authService
            .getGamesPlayedHistory(this.profileService.authService.userProfile.emailAddress!)
            .subscribe((response: HttpResponse<GameStatus[]>) => {
                this.gamePlayedHistory = response.body as GameStatus[];
                console.log(response);
            });
    }
}
