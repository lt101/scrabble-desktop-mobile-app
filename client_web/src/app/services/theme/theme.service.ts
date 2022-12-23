import { Injectable, Renderer2, RendererFactory2 } from '@angular/core';
import { ColorScheme } from '@app/classes/user-preferences/user-preferences';
import { BehaviorSubject } from 'rxjs';
@Injectable({
    providedIn: 'root',
})
export class ThemeService {
    colorScheme: BehaviorSubject<ColorScheme> = new BehaviorSubject<ColorScheme>(ColorScheme.Light);
    colorSchemeObservable = this.colorScheme.asObservable();

    private colorSchemeAttrName = 'color-scheme';
    private renderer: Renderer2;

    constructor(rendererFactory: RendererFactory2) {
        this.renderer = rendererFactory.createRenderer(null, null);
        this.init();
    }

    init() {
        this.colorScheme.next(this._getColorScheme());
        this.set(this.colorScheme.getValue());
    }

    _getColorScheme() {
        const localStorageColorScheme = localStorage.getItem('scheme');
        return localStorageColorScheme !== null ? (localStorageColorScheme as ColorScheme) : ColorScheme.Light;
    }

    set(scheme: ColorScheme) {
        this.colorScheme.next(scheme);
        this.renderer.setAttribute(document.firstElementChild, this.colorSchemeAttrName, scheme);
        localStorage.setItem('scheme', scheme);
    }
}
