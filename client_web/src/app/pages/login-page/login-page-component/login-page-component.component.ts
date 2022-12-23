import { HttpResponse } from '@angular/common/http';
import { Component, OnInit } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { ColorScheme, UserPreferences } from '@app/classes/user-preferences/user-preferences';
import { UserProfile } from '@app/classes/user-profile/user-profile';
// import { Router } from '@angular/router';
import { MAIL_ADDRESS_PATTERN, NAME_MAX_LENGTH } from '@app/constants/create-game';
import { AuthService } from '@app/services/authentication/auth-service.service';
import { ThemeService } from '@app/services/theme/theme.service';
import { TranslocoService } from '@ngneat/transloco';
@Component({
    selector: 'app-login-page-component',
    templateUrl: './login-page-component.component.html',
    styleUrls: ['./login-page-component.component.scss'],
})
export class LoginPageComponentComponent implements OnInit {
    mailAddress: string = '';
    password: string = '';
    paramsForm: FormGroup;
    show: boolean = true;
    signInError: string = '';

    constructor(
        private authService: AuthService,
        private router: Router,
        private themeService: ThemeService,
        private readonly translocoService: TranslocoService,
    ) {}

    ngOnInit(): void {
        this.paramsForm = new FormGroup({
            mailAddress: new FormControl('', [Validators.required, Validators.pattern(MAIL_ADDRESS_PATTERN)]),
            password: new FormControl('', [Validators.maxLength(NAME_MAX_LENGTH)]),
        });
    }

    showPassword() {
        this.show = !this.show;
    }

    logIn(): void {
        const email: string = this.paramsForm.get('mailAddress')!.value;
        const password: string = this.paramsForm.get('password')!.value;
        if ((email || password) == '') this.signInError = this.translocoService.translate('loginPage.emptyField');
        else {
            this.authService.signIn(email, password).subscribe(
                (response: HttpResponse<any>) => {
                    this.authService.userProfile = response.body.newUserProfile;
                    this.authService.isLoggedIn = true;
                    this.authService.authStatus.next(true);
                    this.authService.setSession(response.body);
                    this.signInError = response.statusText;
                    this.router.navigate(['/home']);
                    this.authService.getUserPreferences(email, this.authService.userProfile.userName!).subscribe(
                        (response: HttpResponse<UserPreferences>) => {
                            const color: ColorScheme = response.body?.visualTheme as ColorScheme;
                            const lang: string = response.body?.language as string;
                            this.themeService.set(color);
                            this.translocoService.setActiveLang(lang);
                            this.translocoService.setDefaultLang(lang);
                        },
                        (error) => {
                            console.log(error);
                        },
                    );
                },
                (error) => {
                    console.log(error);
                    this.authService.isLoggedIn = false;
                    this.authService.authStatus.next(false);
                    switch (error.status) {
                        case 401:
                            this.signInError = this.translocoService.translate('loginPage.incorrectPassword');
                            break;
                        case 403:
                            this.signInError = "L'utilisateur est déja connecté";
                            break;
                        case 404:
                            this.signInError = "Cette adresse mail n'est associée à aucun compte";
                            break;
                        default:
                            this.signInError = 'Erreur de connexion';
                    }
                },
            );
        }
    }

    translateRankLevel(userProfile: UserProfile) {}
}
