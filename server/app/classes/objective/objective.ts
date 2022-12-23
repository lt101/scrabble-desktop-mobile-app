import { ObjectiveType } from './objective-type';

export interface Objective {
    id: string;
    title: string;
    description: string;
    points: number;
    type: ObjectiveType;
    checked: boolean;
    done: boolean;
    code: number;
}
