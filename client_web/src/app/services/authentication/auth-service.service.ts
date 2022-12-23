import { HttpClient, HttpResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Connection } from '@app/classes/connection/connection';
import { GameStatus } from '@app/classes/game-status/game-status';
import { UserPreferences } from '@app/classes/user-preferences/user-preferences';
import { UserProfile } from '@app/classes/user-profile/user-profile';
import * as moment from 'moment';
import { BehaviorSubject, Observable } from 'rxjs';
import { environment } from 'src/environments/environment';
import { LocalStorageService } from '../storage/storage.service';

@Injectable({
    providedIn: 'root',
})
export class AuthService {
    isLoggedIn: boolean;
    authStatus: BehaviorSubject<boolean> = new BehaviorSubject<boolean>(false); // optional, might be useful later
    authStatusObservable = this.authStatus.asObservable();
    userProfile: UserProfile;
    URL: string = environment.serverUrl;

    constructor(private readonly http: HttpClient, public localStorageService: LocalStorageService) {
        let userProfileString = '';
        if (!this.userProfile && this.localStorageService.getUserProfile() !== null) {
            userProfileString = this.localStorageService.getUserProfile()!;
            this.userProfile = JSON.parse(userProfileString) as UserProfile;
        }

        // this.localStorageService.removeUserProfile();
    }

    register(email: string, password: string, username: string): Observable<HttpResponse<UserProfile>> {
        return this.http.post<UserProfile>(
            `${this.URL}/api/auth/register`,
            { emailAddress: email, password: password, userName: username },
            { observe: 'response' },
        );
    }

    signIn(email: string, password: string): Observable<HttpResponse<any>> {
        return this.http.post<UserProfile>(`${this.URL}/api/auth/sign-in`, { emailAddress: email, password: password }, { observe: 'response' });
    }

    signOut(email: string) {
        console.log(JSON.stringify(this.userProfile));
        return this.http.patch<any>(`${this.URL}/api/auth/${this.userProfile.userName}/sign-out`, { emailAddress: email }, { observe: 'response' });
    }

    getConnectionHistory(email: string): Observable<HttpResponse<Connection[]>> {
        const headers = { 'Content-Type': 'application/json; charset=UTF-8' };
        return this.http.post<Connection[]>(
            `${this.URL}/api/user-info/${this.userProfile.userName}/connection-history`,
            { emailAddress: email },
            { headers, observe: 'response' },
        );
    }

    getGamesPlayedHistory(email: string): Observable<HttpResponse<GameStatus[]>> {
        return this.http.post<GameStatus[]>(
            `${this.URL}/api/user-info/${this.userProfile.userName}/game-played-history`,
            { emailAddress: email },
            { observe: 'response' },
        );
    }

    getUserPreferences(email: string, username: string): Observable<HttpResponse<UserPreferences>> {
        return this.http.post<UserPreferences>(
            `${this.URL}/api/user-info/${username}/data-persistence`,
            { emailAddress: email },
            { observe: 'response' },
        );
    }

    setSession(authResult: any) {
        const expiresAt = moment().add(authResult.expiresIn, 'second');

        this.localStorageService.storeUserProfile(this.userProfile);
        localStorage.setItem('id_token', authResult.idToken);
        localStorage.setItem('expires_at', JSON.stringify(expiresAt.valueOf()));
    }

    logout() {
        localStorage.removeItem('id_token');
        localStorage.removeItem('expires_at');
    }

    public isLoggedIn_() {
        return moment().isBefore(this.getExpiration());
    }

    getExpiration() {
        const expiration = localStorage.getItem('expires_at');
        const expiresAt = JSON.parse(expiration!);
        return moment(expiresAt);
    }
}
