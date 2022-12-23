import { Injectable } from '@angular/core';
import { ActivatedRouteSnapshot, CanActivate, Router, RouterStateSnapshot } from '@angular/router';
import { AuthService } from '../authentication/auth-service.service';

@Injectable({
    providedIn: 'root',
})
export class AuthGuard implements CanActivate {
    constructor(private authService: AuthService, private router: Router) {}
    isAuthenticated: boolean;

    canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): Promise<boolean> | boolean {
        this.authService.authStatusObservable.subscribe((authStatus) => {
            // subscribing is optional
            // this.isAuthenticated = authStatus;
            this.isAuthenticated = this.authService.isLoggedIn_();
        });

        if (!this.isAuthenticated) {
            this.router.navigate(['/login']);
        }
        return this.isAuthenticated;
    }
}
