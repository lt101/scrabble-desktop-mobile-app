import { Component, OnInit } from '@angular/core';
import { SidebarInformations } from '@app/classes/sidebar/sidebar-informations';
import { GameService } from '@app/services/game/game.service';
import { GridManagerService } from '@app/services/grid/grid-manager/grid-manager.service';
import { SidebarService } from '@app/services/sidebar/sidebar.service';

@Component({
    selector: 'app-play-button',
    templateUrl: './play-button.component.html',
    styleUrls: ['./play-button.component.scss'],
})
export class PlayButtonComponent implements OnInit {
    isCurrentPlayer: boolean;
    isObserver: boolean = false;

    constructor(private readonly gridManager: GridManagerService, private readonly gameService: GameService, public sideBarService: SidebarService) {}

    ngOnInit(): void {
        this.sideBarService.getSidebarInformations().subscribe((sidebarInformations: SidebarInformations) => {
            this.isObserver = sidebarInformations.isObserver;
        });
        this.gameService.getCurrentPlayerObservable().subscribe(this.handleTurn.bind(this));
    }

    handleTurn(onCurrentPlayer: boolean) {
        this.isCurrentPlayer = onCurrentPlayer;
    }

    play() {
        this.gridManager.handleEnter();
    }
}
