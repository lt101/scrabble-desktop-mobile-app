import { Component, OnInit } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { SidebarInformations } from '@app/classes/sidebar/sidebar-informations';
import { GameService } from '@app/services/game/game.service';
import { SidebarService } from '@app/services/sidebar/sidebar.service';
import { ClueDialogComponent } from '../clue-dialog/clue-dialog.component';

@Component({
    selector: 'app-clue-button',
    templateUrl: './clue-button.component.html',
    styleUrls: ['./clue-button.component.scss'],
})
export class ClueButtonComponent implements OnInit {
    isObserver: boolean = false;
    isCurrentPlayer: boolean;

    constructor(public dialog: MatDialog, public sideBarService: SidebarService, private readonly gameService: GameService) {}

    ngOnInit(): void {
        this.sideBarService.getSidebarInformations().subscribe((sidebarInformations: SidebarInformations) => {
            this.isObserver = sidebarInformations.isObserver;
        });
        this.gameService.getCurrentPlayerObservable().subscribe(this.handleTurn.bind(this));
    }

    handleTurn(onCurrentPlayer: boolean) {
        this.isCurrentPlayer = onCurrentPlayer;
    }

    openClueDialog(): void {
        this.dialog.open(ClueDialogComponent);
    }
}
