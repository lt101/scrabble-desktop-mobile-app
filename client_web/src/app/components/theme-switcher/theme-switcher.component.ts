import { HttpResponse } from '@angular/common/http';
import { Component } from '@angular/core';
import { ColorScheme } from '@app/classes/user-preferences/user-preferences';
import { ProfileService } from '@app/services/profile/profile.service';
import { ThemeService } from '@app/services/theme/theme.service';

@Component({
    selector: 'app-theme-switcher',
    templateUrl: './theme-switcher.component.html',
    styleUrls: ['./theme-switcher.component.scss'],
})
export class ThemeSwitcherComponent {
    currentScheme: ColorScheme;
    constructor(private themeService: ThemeService, private profileService: ProfileService) {
        this.themeService.colorSchemeObservable.subscribe((value) => {
            this.currentScheme = value;
        });
        this.themeService.set(this.currentScheme);
        localStorage.setItem('scheme', this.currentScheme);
    }

    setTheme() {
        const scheme = this.currentScheme == ColorScheme.Dark ? ColorScheme.Light : ColorScheme.Dark;
        this.themeService.set(scheme);
        this.currentScheme = scheme;
        this.profileService.sendThemePreference(this.profileService.authService.userProfile.emailAddress!, scheme).subscribe(
            (response: HttpResponse<any>) => {
                console.log(response);
            },
            (error) => {
                console.log(error);
            },
        );
    }
}
