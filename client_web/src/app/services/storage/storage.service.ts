import { Injectable } from '@angular/core';
import { UserProfile } from '@app/classes/user-profile/user-profile';

@Injectable({
    providedIn: 'root',
})
export class LocalStorageService {
    constructor() {}
    storeUserProfile(userProfile: UserProfile) {
        localStorage.setItem('UserProfile', JSON.stringify(userProfile));
    }

    getUserProfile() {
        return localStorage.getItem('UserProfile');
    }

    removeUserProfile() {
        localStorage.removeItem('UserProfile');
    }
}
