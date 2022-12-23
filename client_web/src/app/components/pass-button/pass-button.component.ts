import { Component, OnInit } from '@angular/core';
import { SidebarInformations } from '@app/classes/sidebar/sidebar-informations';
import { PassTurnService } from '@app/services/pass-turn/pass-turn.service';
import { SidebarService } from '@app/services/sidebar/sidebar.service';

@Component({
    selector: 'app-pass-button',
    templateUrl: './pass-button.component.html',
    styleUrls: ['./pass-button.component.scss'],
})
export class PassButtonComponent implements OnInit {
    isCurrentPlayer: boolean = false;
    isObserver: boolean = false;
    constructor(private readonly passTurnService: PassTurnService, public sideBarService: SidebarService) {}

    ngOnInit(): void {
        this.sideBarService.getSidebarInformations().subscribe((sidebarInformations: SidebarInformations) => {
            this.isObserver = sidebarInformations.isObserver;
        });
        this.passTurnService.isCurrentPlayer().subscribe((isCurrentPlayer) => (this.isCurrentPlayer = isCurrentPlayer));
    }

    passTurn(): void {
        this.passTurnService.passTurn();
    }
}
