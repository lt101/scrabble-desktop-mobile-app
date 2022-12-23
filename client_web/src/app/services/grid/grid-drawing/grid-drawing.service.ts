import { Injectable } from '@angular/core';
import { Box } from '@app/classes/grid/box';
import { Grid } from '@app/classes/grid/grid';
import { AXIS } from '@app/classes/grid/placement';
import { Vec2 } from '@app/classes/grid/vec2';
import { ColorScheme } from '@app/classes/user-preferences/user-preferences';
import { bankLetters } from '@app/constants/easel';
import {
    ARRAY_SIZE,
    BLACK,
    CENTER,
    FONT_CONSTANTS,
    HORIZONTAL_ARROW,
    INDICATORS_FONT,
    Multiplier,
    OFFSET,
    STAR,
    STAR_FONT,
    VERTICAL_ARROW,
    WORD_OFFSET,
    YELLOW,
} from '@app/constants/grid';
import { ThemeService } from '@app/services/theme/theme.service';

@Injectable({
    providedIn: 'root',
})
export class GridDrawingService {
    gridContext: CanvasRenderingContext2D;
    fontSize: number = FONT_CONSTANTS.defaultFontSize;
    grid: Grid;
    boxWidth: number;
    boxHeight: number;
    isDarkTheme: boolean;

    private canvasSize: Vec2;

    constructor(private themeService: ThemeService) {
        this.grid = Grid.getGrid();
        this.themeService.colorSchemeObservable.subscribe((color) => {
            this.isDarkTheme = color === ColorScheme.Dark;
        });
    }

    setSize(size: Vec2): void {
        this.canvasSize = size;
        this.boxWidth = this.canvasSize.x / ARRAY_SIZE;
        this.boxHeight = this.canvasSize.y / ARRAY_SIZE;
    }

    generateRoundRect(x0: number, y0: number, x1: number, y1: number, r: number, color: string) {
        const ctx = this.gridContext.canvas.getContext('2d')!;
        var w = x1 - x0;
        var h = y1 - y0;
        if (r > w / 2) r = w / 2;
        if (r > h / 2) r = h / 2;
        ctx.beginPath();
        ctx.moveTo(x1 - r, y0);
        ctx.quadraticCurveTo(x1, y0, x1, y0 + r);
        ctx.lineTo(x1, y1 - r);
        ctx.quadraticCurveTo(x1, y1, x1 - r, y1);
        ctx.lineTo(x0 + r, y1);
        ctx.quadraticCurveTo(x0, y1, x0, y1 - r);
        ctx.lineTo(x0, y0 + r);
        ctx.quadraticCurveTo(x0, y0, x0 + r, y0);
        ctx.closePath();
        ctx.fillStyle = color;
        ctx.fill();
    }

    /**
     * Dessine la grille
     */
    drawGrid(): void {
        this.gridContext.beginPath();

        this.drawIndicators();
        this.drawRowsColumns();
        this.drawStar();
        this.gridContext.stroke();
    }

    /**
     * Clear l'intérieur du box
     *
     * @param box le box pour vider
     */
    clearBox(box: Box) {
        this.gridContext.lineWidth = 5;
        this.gridContext.fillStyle = box.color;
        this.gridContext.fillRect(this.boxWidth * box.x, this.boxHeight * box.y, this.boxWidth, this.boxHeight);

        this.gridContext.strokeStyle = this.isDarkTheme ? '#3a506b' : 'rgba(221, 205, 153, 255)';
        this.generateRoundRect(
            this.boxWidth * box.x,
            this.boxHeight * box.y,
            this.boxWidth * box.x + this.boxWidth,
            this.boxHeight * box.y + this.boxHeight,
            7,
            '',
        );
        this.gridContext.stroke();
    }

    /**
     * Met a jour le fontSize
     *
     * @param value la valeur incrementer du fontSize
     */
    updateFontSize(value: number): void {
        this.fontSize = this.fontSizeOutOfBounds(value) ? this.fontSize : this.fontSize + value;
    }

    /**
     * Dessine la flèche
     *
     * @param box Dessine la flèche dans le box du grid
     * @param direction de la flèche
     */
    drawArrow(box: Box, direction: AXIS): void {
        this.gridContext.font = FONT_CONSTANTS.arrowStyle;
        this.gridContext.fillStyle = BLACK;
        this.gridContext.fillText(
            direction === AXIS.Horizontal ? HORIZONTAL_ARROW : VERTICAL_ARROW,
            box.x * this.boxHeight + ARRAY_SIZE,
            box.y * this.boxWidth + ARRAY_SIZE * 2,
        );
    }

    /**
     * Dessine la bordure du box en jaune ou noir
     *
     * @param box le box a affecter avecla bordure jaune
     * @param value true si c'est jaune, false si c'est noir
     */
    highlightedBorder(box: Box, value: boolean): void {
        this.gridContext.strokeStyle = value ? YELLOW : BLACK;
        this.gridContext.strokeRect(this.boxWidth * box.x, this.boxHeight * box.y, this.boxWidth, this.boxHeight);
    }
    /**
     * dessine le contenu de la box
     *
     * @param box boxe à dessiner
     */
    drawBoxContent(box: Box): void {
        this.clearBox(box);
        if (box.x === CENTER.x && box.y === CENTER.y && box.value === '') {
            this.drawStar();
            return;
        }
        if (box.value === '' && box.multiplier !== Multiplier.Basic) {
            this.drawMultiplier(box);
            return;
        }
        this.drawCharacter(box);
    }
    /**
     * Détecte la position de la souris
     *
     * @param pos Position de la souris
     * @return Position de la case
     */
    detectBoxPosition(pos: Vec2): Vec2 {
        const x = Math.ceil(pos.x / this.boxWidth) - 1;
        const y = Math.ceil(pos.y / this.boxHeight) - 1;
        return { x: y, y: x };
    }
    /**
     * Dessine le charactere de la boxe
     *
     * @param box la box correspondante
     */
    private drawCharacter(box: Box): void {
        if (box.value !== '') {
            // draw background
            this.gridContext.fillStyle = 'rgba(250, 234, 194, 1)';
            // this.gridContext.fillRect(this.boxWidth * box.x, this.boxHeight * box.y, this.boxWidth, this.boxHeight);
            this.generateRoundRect(
                this.boxWidth * box.x + 1.5,
                this.boxHeight * box.y + 1.5,
                this.boxWidth * box.x + this.boxWidth - 1.5,
                this.boxHeight * box.y + this.boxHeight - 1.5,
                7,
                'rgba(250, 234, 194, 1)',
            );
            // draw letter
            this.gridContext.font = `700 16px Nunito`;
            this.gridContext.fillStyle = BLACK;
            this.gridContext.fillText(box.value.toUpperCase(), box.x * this.boxWidth + ARRAY_SIZE - 3, box.y * this.boxHeight + OFFSET - 6);

            // draw letter value
            const points = bankLetters.find((l) => l.letter === box.value.toUpperCase())?.point;
            const offset = points! > 9 ? 3 : 0; // if letter value is 10
            this.gridContext.font = `bold 9px Nunito`;

            this.gridContext.fillText(
                points!.toString(),
                box.x * this.boxWidth + this.boxWidth / 1.4 - offset,
                box.y * this.boxHeight + this.boxHeight / 1.2,
            );
        }
    }
    /**
     * Dessine le multiplier de la case
     *
     * @param box la boxe correspondante
     */
    private drawMultiplier(box: Box): void {
        this.gridContext.font = FONT_CONSTANTS.defaultMultiplierFont;
        this.gridContext.fillStyle = BLACK;
        this.gridContext.fillText(
            this.changeMultiplierLabel(box.multiplier),
            box.x * this.boxWidth + WORD_OFFSET + 5.5,
            box.y * this.boxHeight + OFFSET - 8,
            this.boxWidth - WORD_OFFSET * 2,
        );
    }

    private changeMultiplierLabel(multiplier: Multiplier) {
        const label: string = multiplier;
        switch (label) {
            case 'WORD X3':
                return 'TW';
            case 'WORD X2':
                return 'DW';
            case 'LETTER X2':
                return 'DL';
            case 'LETTER X3':
                return 'TL';
            default:
                return label;
        }
    }

    /**
     * Indique si la police dépasse des bordures
     *
     * @param value Taille de la police
     * @returns Booléen qui indique si la police dépasse des bordures
     */

    private fontSizeOutOfBounds(value: number): boolean {
        return this.fontSize + value < FONT_CONSTANTS.minFontSize || this.fontSize + value > FONT_CONSTANTS.maxFontSize;
    }

    /**
     * Dessine les indicteurs (lettres et chiffres autour de la grid)
     */
    private drawIndicators(): void {
        this.gridContext.strokeStyle = BLACK;
        this.gridContext.fillStyle = this.isDarkTheme ? 'white' : BLACK;
        this.gridContext.font = INDICATORS_FONT;
        for (let i = 1; i < ARRAY_SIZE; i++) {
            this.gridContext.fillText(this.grid.boxes[0][i].value, i * this.boxWidth + ARRAY_SIZE, OFFSET);
            this.gridContext.fillText(this.grid.boxes[i][0].value, ARRAY_SIZE, i * this.boxHeight + OFFSET);
        }
    }

    /**
     * Dessine le contenu de la grille
     */
    private drawRowsColumns(): void {
        this.gridContext.lineWidth = 1;
        for (let j = 1; j < ARRAY_SIZE; j++) for (let i = 1; i < ARRAY_SIZE; i++) this.drawBoxContent(this.grid.boxes[i][j]);
    }

    /**
     * Dessine l'étoile
     */
    private drawStar(): void {
        if (this.grid.boxes[CENTER.x][CENTER.y].value === '') {
            this.gridContext.font = STAR_FONT;
            this.gridContext.fillText(STAR, CENTER.x * this.boxWidth + this.boxWidth / 4, (CENTER.y + 1) * this.boxHeight - this.boxHeight / 3);
        }
    }

    get width(): number {
        return this.canvasSize.x;
    }

    set width(x: number) {
        this.canvasSize.x = x;
    }

    set height(y: number) {
        this.canvasSize.y = y;
    }

    get height(): number {
        return this.canvasSize.y;
    }
}
