import { Objective } from '@app/classes/objective/objective';
import { OBJECTIVES, OBJECTIVES_NUMBER } from '@app/constants/objectives';
import { Service } from 'typedi';

@Service()
export class ObjectivesManagerService {
    /**
     * Retourne un nombre aléatoire entre 0 et size - 1
     *
     * @param size Borne supérieure
     * @returns Nombre aléatoire entre 0 et size - 1
     */
    getRandomNumber(size: number): number {
        return Math.floor(Math.random() * size);
    }

    /**
     * Indique si un objectif est choisi
     *
     * @param objective Objectif à vérifier
     * @param publicObjectives Liste des objectifs publics
     * @returns Booléen qui indique si l'objectif est choisi
     */
    isObjectiveChoosen(objective: Objective, publicObjectives: Objective[]): boolean {
        for (const obj of publicObjectives) if (obj === objective) return true;
        return false;
    }

    /**
     * Retourne des objectifs choisi aléatoirement
     *
     * @returns Objectifs aléatoires
     */
    getRandomObjectives(): Objective[] {
        const choosenObjectives: Objective[] = [];
        for (let index = 0; index < OBJECTIVES_NUMBER; index++) {
            let random = this.getRandomNumber(OBJECTIVES.length);
            while (this.isObjectiveChoosen(OBJECTIVES[random], choosenObjectives)) random = this.getRandomNumber(OBJECTIVES.length);
            choosenObjectives.push(OBJECTIVES[random]);
        }
        return choosenObjectives;
    }

    /**
     * Retourne les objectifs de la partie
     *
     * @returns Objectifs publics et privés
     */
    getGameObjectives(): Objective[] {
        return this.getRandomObjectives();
    }
}
