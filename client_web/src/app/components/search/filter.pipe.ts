import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
    name: 'filter',
})
export class FilterPipe implements PipeTransform {
    transform(array: string[], input: string): any {
        if (input) return array.filter((val) => val.indexOf(input) >= 0);
        else return array;
    }
}
