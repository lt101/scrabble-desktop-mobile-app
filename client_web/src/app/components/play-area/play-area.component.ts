import { CdkDragDrop, moveItemInArray } from '@angular/cdk/drag-drop';
//import { Container } from '@angular/compiler/src/i18n/i18n_ast';
import { AfterViewInit, Component, ElementRef, HostListener, OnInit, ViewChild } from '@angular/core';
import { Letter } from '@app/classes/common/letter';
import { COMPONENT } from '@app/classes/control/component';
import { Box } from '@app/classes/grid/box';
import { Grid } from '@app/classes/grid/grid';
import { Positions } from '@app/classes/position/positions';
import { GameDisplayService } from '@app/services/game-display/game-display.service';
import { GameService } from '@app/services/game/game.service';
import { GridDrawingService } from '@app/services/grid/grid-drawing/grid-drawing.service';
import { GridManagerService } from '@app/services/grid/grid-manager/grid-manager.service';
import { GridService } from '@app/services/grid/grid/grid.service';
import { KeyboardHandlerService } from '@app/services/keyboard/keyboard-handler.service';
import { MouseService } from '@app/services/mouse/mouse.service';
import { MusicService } from '@app/services/music/music.service';

@Component({
    selector: 'app-play-area',
    templateUrl: './play-area.component.html',
    styleUrls: ['./play-area.component.scss'],
})
export class PlayAreaComponent implements AfterViewInit, OnInit {
    @ViewChild('gridCanvas', { static: false }) private gridCanvas!: ElementRef<HTMLCanvasElement>;
    @ViewChild('grid') grid: ElementRef;

    buttonPressed = '';
    isCurrentController: boolean = false;
    isCurrentPlayer: boolean = false;
    gridOfBox: Box[][];
    boundOfGrid: DOMRect;

    constructor(
        private readonly gridService: GridService,
        private readonly gameDisplayService: GameDisplayService,
        private readonly mouseService: MouseService,
        public gridManagerService: GridManagerService,
        private readonly keyboardHandler: KeyboardHandlerService,
        private readonly gameService: GameService,
        public gridDrawingService: GridDrawingService,
        private readonly musicService: MusicService,
    ) {
        this.keyboardHandler.getCurrentController().subscribe(this.handleControllerChange.bind(this));
        this.gameService.getCurrentPlayerObservable().subscribe(this.handlePlayerChange.bind(this));
    }
    ngOnInit(): void {
        this.gridOfBox = this.gridService.grid.boxes;
    }
    @HostListener('keydown', ['$event'])
    buttonDetect(event: KeyboardEvent): void {
        if (!this.isCurrentController || !this.isCurrentPlayer) return;
        this.buttonPressed = event.key;
        this.gridManagerService.handleKeyPressed(this.buttonPressed);
    }

    ngAfterViewInit(): void {
        const width = this.gridCanvas.nativeElement.parentElement?.clientHeight || 0;
        this.gridCanvas.nativeElement.width = width + 35;
        this.gridCanvas.nativeElement.height = width + 35;
        this.gridDrawingService.gridContext = this.gridCanvas.nativeElement.getContext('2d') as CanvasRenderingContext2D;
        this.gridDrawingService.setSize({ x: width, y: width });
        this.gridCanvas.nativeElement.focus();
        this.subscribe();
    }

    subscribe(): void {
        this.gameDisplayService.onUpdateGrid().subscribe((grid: Grid) => {
            this.gridService.updateGrid(grid);
            this.gridDrawingService.drawGrid();
            this.musicService.playWordMusic();
            this.gridManagerService.allCases = new Array<Letter>(225).fill({ letter: '', point: 106 }).map((_) => _);
        });
    }

    mouseHitDetect(event: MouseEvent) {
        this.keyboardHandler.takeControl(COMPONENT.GRID);
        this.mouseService.mouseHitDetect(event);
        event.stopPropagation();
    }

    handleControllerChange(component: COMPONENT): void {
        this.isCurrentController = component === COMPONENT.GRID;
    }

    handlePlayerChange(isCurrentPlayer: boolean): void {
        this.isCurrentPlayer = isCurrentPlayer;
        this.gridService.isCurrentPlayer = isCurrentPlayer;
    }

    get width(): number {
        return this.gridDrawingService.width;
    }

    get height(): number {
        return this.gridDrawingService.height;
    }
    dropped(event: CdkDragDrop<Letter[]>) {
        this.boundOfGrid = this.grid.nativeElement.getBoundingClientRect();
        this.gridManagerService.positions = Positions.createPositions(this.boundOfGrid.x, this.boundOfGrid.y);
        let index = this.gridManagerService.closestIndex(event, this.boundOfGrid.x, this.boundOfGrid.y).index;
        if (event.previousContainer === event.container) {
            moveItemInArray(event.container.data, event.previousIndex, index);
        } else {
            if (this.gridManagerService.allCases[index].point == 106) {
                this.gridManagerService.allCases[index] = event.previousContainer.data[event.previousIndex];
                event.previousContainer.data.splice(event.previousIndex, 1);
            }
        }
    }
}
