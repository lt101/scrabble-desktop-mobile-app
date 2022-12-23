import { Component, OnInit } from '@angular/core';
import { SidebarInformations } from '@app/classes/sidebar/sidebar-informations';
import { EaselService } from '@app/services/easel/easel/easel.service';
import { GameService } from '@app/services/game/game.service';
import { SidebarService } from '@app/services/sidebar/sidebar.service';

@Component({
    selector: 'app-exchange-button',
    templateUrl: './exchange-button.component.html',
    styleUrls: ['./exchange-button.component.scss'],
})
export class ExchangeButtonComponent implements OnInit {
    isCurrentPlayer: boolean;
    onExchange: boolean = false;
    isObserver: boolean = false;

    constructor(private readonly easelService: EaselService, private readonly gameService: GameService, public sideBarService: SidebarService) {}

    ngOnInit(): void {
        this.sideBarService.getSidebarInformations().subscribe((sidebarInformations: SidebarInformations) => {
            this.isObserver = sidebarInformations.isObserver;
        });
        this.easelService.getExchange().subscribe(this.handleExchange.bind(this));
        this.gameService.getCurrentPlayerObservable().subscribe(this.handleTurn.bind(this));
    }

    exchange() {
        this.easelService.exchangeLetters();
    }
    handleExchange(onExchange: boolean) {
        this.onExchange = onExchange;
    }
    handleTurn(onCurrentPlayer: boolean) {
        this.isCurrentPlayer = onCurrentPlayer;
    }
}
