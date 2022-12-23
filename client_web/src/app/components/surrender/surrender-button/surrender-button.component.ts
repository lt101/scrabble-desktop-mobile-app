import { Component } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { SidebarInformations } from '@app/classes/sidebar/sidebar-informations';
import { SurrenderDialogComponent } from '@app/components/surrender/surrender-dialog/surrender-dialog.component';
import { QUIT_GAME } from '@app/constants/events';
import { GameService } from '@app/services/game/game.service';
import { RoomService } from '@app/services/room/room.service';
import { SidebarService } from '@app/services/sidebar/sidebar.service';
import { SocketManagerService } from '@app/services/socket-manager/socket-manager.service';

@Component({
    selector: 'app-surrender-button',
    templateUrl: './surrender-button.component.html',
    styleUrls: ['./surrender-button.component.scss'],
})
export class SurrenderButtonComponent {
    isObserver: boolean = false;

    constructor(
        public dialog: MatDialog,
        public sideBarService: SidebarService,
        private readonly router: Router,
        private readonly socketManagerService: SocketManagerService,
        private readonly gameService: GameService,
        private readonly roomService: RoomService,
    ) {}

    ngOnInit(): void {
        this.sideBarService.getSidebarInformations().subscribe((sidebarInformations: SidebarInformations) => {
            this.isObserver = sidebarInformations.isObserver;
        });
        this.socketManagerService.on(QUIT_GAME, () => {
            this.quitGameObservation();
        });
    }

    surrender(): void {
        this.dialog.open(SurrenderDialogComponent);
    }

    quitGameObservation(): void {
        this.socketManagerService.emit('game:observer_quit', this.gameService.getId());
        this.router.navigate(['/home']);
        this.roomService.handleReload();
    }
}
