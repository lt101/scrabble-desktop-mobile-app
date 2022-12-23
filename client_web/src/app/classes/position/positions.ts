import { distanceBetweenBoxes, gridLength } from '@app/constants/dropPoints';
import { Position } from './position';

export class Positions {
    static createPositions(x: number, y: number): Array<Position> {
        let positions: Array<Position> = [];
        let position = { index: 0, x: x + 20, y: y + 20, col: 0, lin: 0 };
        for (let i = 0; i < gridLength; i++) {
            for (let j = 0; j < gridLength; j++) {
                positions.push(position);
                position = {
                    index: position.index + 1,
                    x: position.x + distanceBetweenBoxes,
                    y: position.y,
                    col: j + 1,
                    lin: i + 1,
                };
            }
            position = { index: position.index, x: x + 20, y: position.y + distanceBetweenBoxes, col: 1, lin: i + 1 };
        }
        return positions;
    }
}
