import { Component, OnInit } from '@angular/core';
import { LanguageHandlerService } from '@app/services/language/language-handler.service';
import { TranslocoService } from '@ngneat/transloco';

@Component({
    selector: 'app-language-selector-component',
    templateUrl: './language-selector-component.component.html',
    styleUrls: ['./language-selector-component.component.scss'],
})
export class LanguageSelectorComponentComponent implements OnInit {
    constructor(private readonly translocoService: TranslocoService, private languageHandleService: LanguageHandlerService) {}
    languageSelectionMessage: string;
    selectedLanguage: string;
    french: string;
    english: string;
    ngOnInit() {
        this.translocoService.selectTranslate('language.languageMessage').subscribe((translation) => {
            this.languageSelectionMessage = translation;
        });
    }
    changeLanguage(value: string): void {
        this.languageHandleService.changeLanguage(value);
    }
}
