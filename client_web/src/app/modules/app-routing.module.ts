import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { AdminPageComponent } from '@app/pages/admin-page/admin-page.component';
import { ChatPageComponent } from '@app/pages/chat-page/chat-page.component';
import { ClassicPageComponent } from '@app/pages/classic-page/classic-page.component';
import { GamePageComponent } from '@app/pages/game-page/game-page.component';
import { HighScoresPageComponent } from '@app/pages/high-scores-page/high-scores-page.component';
import { Log2990PageComponent } from '@app/pages/log2990-page/log2990-page.component';
import { LoginPageComponentComponent } from '@app/pages/login-page/login-page-component/login-page-component.component';
import { MainPageComponent } from '@app/pages/main-page/main-page.component';
import { MaterialPageComponent } from '@app/pages/material-page/material-page.component';
import { MultiplayerCreatePageComponent } from '@app/pages/multiplayer-create-page/multiplayer-create-page.component';
import { MultiplayerJoinPageComponent } from '@app/pages/multiplayer-join-page/multiplayer-join-page.component';
import { MultiplayerPageComponent } from '@app/pages/multiplayer-page/multiplayer-page.component';
import { MultiplayerWaitingPageComponent } from '@app/pages/multiplayer-waiting-page/multiplayer-waiting-page.component';
import { RegisterPageComponentComponent } from '@app/pages/register-page/register-page-component/register-page-component.component';
import { SoloCreatePageComponent } from '@app/pages/solo-create-page/solo-create-page.component';
import { AuthGuard } from '@app/services/auth-guard/auth.guard';

const multiplayerChildren: Routes = [
    { path: 'create', component: MultiplayerCreatePageComponent, canActivate: [AuthGuard] },
    { path: 'join', component: MultiplayerJoinPageComponent, canActivate: [AuthGuard] },
    { path: 'waiting', component: MultiplayerWaitingPageComponent, canActivate: [AuthGuard] },
];

const childrenRoutes: Routes = [
    { path: 'material', component: MaterialPageComponent },
    { path: 'multiplayer', children: [{ path: '', component: MultiplayerPageComponent }, ...multiplayerChildren], canActivate: [AuthGuard] },
    { path: 'solo', component: SoloCreatePageComponent, children: [{ path: '', component: SoloCreatePageComponent }], canActivate: [AuthGuard] },
];

const routes: Routes = [
    { path: '', redirectTo: '/home', pathMatch: 'full' },
    { path: 'login', component: LoginPageComponentComponent },
    { path: 'register', component: RegisterPageComponentComponent },
    { path: 'home', component: MainPageComponent, canActivate: [AuthGuard] },
    { path: 'chat', component: ChatPageComponent, canActivate: [AuthGuard] },
    { path: 'classic', children: [{ path: '', component: ClassicPageComponent }, ...childrenRoutes] },
    { path: 'log2990', children: [{ path: '', component: Log2990PageComponent }, ...childrenRoutes], canActivate: [AuthGuard] },
    { path: 'high-scores', component: HighScoresPageComponent, canActivate: [AuthGuard] },
    { path: 'game', component: GamePageComponent, canActivate: [AuthGuard] },
    { path: 'admin', component: AdminPageComponent, canActivate: [AuthGuard] },
    { path: '**', redirectTo: '/home' },
];

@NgModule({
    imports: [RouterModule.forRoot(routes, { useHash: true })],
    exports: [RouterModule],
    providers: [AuthGuard],
})
export class AppRoutingModule {}
