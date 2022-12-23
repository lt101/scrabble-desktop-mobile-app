import { Component, OnInit } from '@angular/core';
import { SidebarInformations } from '@app/classes/sidebar/sidebar-informations';
import { EaselService } from '@app/services/easel/easel/easel.service';
import { GameService } from '@app/services/game/game.service';
import { SidebarService } from '@app/services/sidebar/sidebar.service';

@Component({
    selector: 'app-cancel-button',
    templateUrl: './cancel-button.component.html',
    styleUrls: ['./cancel-button.component.scss'],
})
export class CancelButtonComponent implements OnInit {
    onExchange: boolean = false;
    isCurrentPlayer: boolean;
    isObserver: boolean = false;
    constructor(private readonly easelService: EaselService, private readonly gameService: GameService, public sideBarService: SidebarService) {}
    ngOnInit() {
        this.sideBarService.getSidebarInformations().subscribe((sidebarInformations: SidebarInformations) => {
            this.isObserver = sidebarInformations.isObserver;
        });
        this.easelService.getExchange().subscribe(this.handleExchange.bind(this));
        this.gameService.getCurrentPlayerObservable().subscribe(this.handleTurn.bind(this));
    }
    handleExchange(onExchange: boolean) {
        this.onExchange = onExchange;
    }
    isButtonActive(): boolean {
        return this.isCurrentPlayer && this.onExchange;
    }
    handleTurn(onCurrentPlayer: boolean) {
        this.isCurrentPlayer = onCurrentPlayer;
    }
    cancelExchange() {
        this.easelService.reset();
    }
}
