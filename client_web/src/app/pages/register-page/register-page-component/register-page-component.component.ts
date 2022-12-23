import { HttpResponse } from '@angular/common/http';
import { Component, OnInit } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { UserProfile } from '@app/classes/user-profile/user-profile';
import { MAIL_ADDRESS_PATTERN, NAME_MAX_LENGTH, NAME_PATTERN, PASSWORD_MAX_LENGTH } from '@app/constants/create-game';
import { AuthService } from '@app/services/authentication/auth-service.service';

@Component({
    selector: 'app-register-page-component',
    templateUrl: './register-page-component.component.html',
    styleUrls: ['./register-page-component.component.scss'],
})
export class RegisterPageComponentComponent implements OnInit {
    mailAddress: string = '';
    username: string = '';
    password: string = '';
    paramsForm: FormGroup;
    show: boolean = true;
    signUpError: string = '';
    constructor(private authService: AuthService, private router: Router) {}

    ngOnInit(): void {
        this.paramsForm = new FormGroup({
            mailAddress: new FormControl('', [Validators.required, Validators.pattern(MAIL_ADDRESS_PATTERN)]),
            username: new FormControl('', [Validators.required, Validators.pattern(NAME_PATTERN), Validators.maxLength(NAME_MAX_LENGTH)]),
            password: new FormControl('', [Validators.maxLength(PASSWORD_MAX_LENGTH)]),
        });
    }

    showPassword() {
        this.show = !this.show;
    }

    register(): void {
        const email: string = this.paramsForm.get('mailAddress')!.value;
        const username: string = this.paramsForm.get('username')!.value;
        const password: string = this.paramsForm.get('password')!.value;
        if (email.length === 0 || username.length === 0 || password.length === 0) this.signUpError = 'Erreur, un champ requis est vide';
        else {
            console.log(email);
            this.authService.register(email, password, username).subscribe(
                (response: HttpResponse<UserProfile>) => {
                    console.log(response.status);
                    this.router.navigate(['/login']);
                },
                (error) => {
                    console.log(error);
                    switch (error.status) {
                        case 201:
                            this.router.navigate(['/login']);
                            break;
                        case 406:
                            this.signUpError = "Le nom d'utilisateur n'est pas disponible";
                            break;
                        case 409:
                            this.signUpError = "L'adresse mail est déjà utilisée";
                            break;
                        default:
                            this.signUpError = 'Erreur inconnue';
                    }
                },
            );
        }
    }
}
