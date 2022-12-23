import { HttpResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { TranslocoService } from '@ngneat/transloco';
import { BehaviorSubject, Observable } from 'rxjs';
import { ProfileService } from '../profile/profile.service';

@Injectable({
    providedIn: 'root',
})
export class LanguageHandlerService {
    activeLanguage: Observable<string>;
    activeLanguageSubject = new BehaviorSubject<string>('fr');
    activeLang: string;
    constructor(private readonly translocoService: TranslocoService, private profileService: ProfileService) {
        this.activeLanguage = this.activeLanguageSubject.asObservable();
    }
    changeLanguage(lang: string) {
        // get active language trans
        this.activeLang = this.translocoService.getActiveLang();
        if (this.activeLang != lang) {
            this.translocoService.setActiveLang(lang);
            this.translocoService.setDefaultLang(lang);
        }

        this.profileService.sendLanguagePreference(this.profileService.authService.userProfile.emailAddress!, lang).subscribe(
            (response: HttpResponse<any>) => {
                console.log(response);
            },
            (error) => {
                console.log(error);
            },
        );
        //update subject avec la bonne valeur
    }
}
