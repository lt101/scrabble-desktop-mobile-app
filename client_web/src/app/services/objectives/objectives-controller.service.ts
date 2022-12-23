import { Injectable } from '@angular/core';
import { Objective } from '@app/classes/objective/objective';
import { EVENT_UPDATE_OBJECTIVES } from '@app/constants/events';
import { SocketManagerService } from '@app/services/socket-manager/socket-manager.service';
import { BehaviorSubject, Observable } from 'rxjs';

@Injectable({
    providedIn: 'root',
})
export class ObjectivesControllerService {
    publicObjectives: BehaviorSubject<Objective[]>;
    constructor(private socketManagerService: SocketManagerService) {
        this.publicObjectives = new BehaviorSubject<Objective[]>([]);
        this.handleEvents();
    }
    /**
     * Gère les évènements
     */
    handleEvents(): void {
        this.socketManagerService.on(EVENT_UPDATE_OBJECTIVES, this.handlePublicObjectivesUpdate.bind(this));
    }

    /**
     * @returns les objectifs publics
     */
    getPublicObjectives(): Observable<Objective[]> {
        return this.publicObjectives.asObservable();
    }

    /**
     * Gère la mise à jour des objectifs publics
     *
     * @param publicObjectives Objectifs publics
     */
    handlePublicObjectivesUpdate(publicObjectives: Objective[]): void {
        this.publicObjectives.next(publicObjectives);
    }
}
