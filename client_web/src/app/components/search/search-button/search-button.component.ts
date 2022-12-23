import { Component, OnInit } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { SidebarInformations } from '@app/classes/sidebar/sidebar-informations';
import { SidebarService } from '@app/services/sidebar/sidebar.service';
import { SearchDialogComponent } from '../search-dialog/search-dialog.component';

@Component({
    selector: 'app-search-button',
    templateUrl: './search-button.component.html',
    styleUrls: ['./search-button.component.scss'],
})
export class SearchButtonComponent implements OnInit {
    isObserver: boolean = false;

    constructor(public dialog: MatDialog, public sideBarService: SidebarService) {}

    ngOnInit(): void {
        this.sideBarService.getSidebarInformations().subscribe((sidebarInformations: SidebarInformations) => {
            this.isObserver = sidebarInformations.isObserver;
        });
    }

    openSearchDialog(): void {
        this.dialog.open(SearchDialogComponent);
    }
}
