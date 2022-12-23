import { HttpClient, HttpResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { UserProfile } from '@app/classes/user-profile/user-profile';
import { Observable } from 'rxjs';
import { environment } from 'src/environments/environment';
import { AuthService } from '../authentication/auth-service.service';

@Injectable({
    providedIn: 'root',
})
export class ProfileService {
    constructor(private readonly http: HttpClient, public authService: AuthService) {}
    URL: string = environment.serverUrl;
    updateUserProfile(email: string): Observable<HttpResponse<UserProfile>> {
        const headers = { 'Content-Type': 'application/json; charset=UTF-8' };

        return this.http.post<UserProfile>(
            `${this.URL}/api/user-info/${this.authService.userProfile.userName}/user-info-update`,
            { emailAddress: email },
            { headers, observe: 'response' },
        );
    }

    sendUsernameToServer(newUsername: string): Observable<HttpResponse<UserProfile>> {
        return this.http.post<UserProfile>(
            `${this.URL}/api/user-info/${this.authService.userProfile.userName}/change-username`,
            { emailAddress: this.authService.userProfile.emailAddress, newUsername: newUsername },
            { observe: 'response' },
        );
    }

    sendAvatarToServer(avatarURL: string) {
        const headers = { 'Content-Type': 'application/json; charset=UTF-8' };
        const body = { emailAddress: this.authService.userProfile.emailAddress, newAvatarUrl: avatarURL };
        this.http.post<any>(`${this.URL}/api/user-info/${this.authService.userProfile.userName}/change-avatar`, body, { headers }).subscribe(
            (res) => {
                console.log(res);
                this.authService.userProfile.avatarUrl = avatarURL;
                this.authService.localStorageService.storeUserProfile(this.authService.userProfile);
                switch (res.statusCode) {
                    case 200:
                        return "L'avatar a été modifié avec succès!";
                    case 400:
                    default:
                        return 'Erreur inconnue';
                }
            },
            (err) => {
                console.log(err);
                return err;
            },
        );
    }
    sendThemePreference(email: string, theme: string): Observable<HttpResponse<any>> {
        return this.http.post<string>(
            `${this.URL}/api/user-info/${this.authService.userProfile.userName}/update-visual-theme`,
            { emailAddress: email, visualTheme: theme },
            { observe: 'response' },
        );
    }

    sendLanguagePreference(email: string, language: string): Observable<HttpResponse<any>> {
        return this.http.post<string>(
            `${this.URL}/api/user-info/${this.authService.userProfile.userName}/update-language`,
            { emailAddress: email, language: language },
            { observe: 'response' },
        );
    }
}
