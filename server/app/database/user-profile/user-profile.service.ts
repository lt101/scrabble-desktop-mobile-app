import { Duration } from '@app/classes/game-history/duration';
import { UserProfile, Grade, Level } from '@app/classes/user-profile/user-profile';
import { DATABASE_COLLECTION } from '@app/constants/user-profile';
import { DatabaseService } from '@app/database/database/database.service';
import { Collection } from 'mongodb';
import 'reflect-metadata';
import { Service } from 'typedi';
@Service()
export class UserProfileService {
    constructor(private databaseService: DatabaseService) {}

    get collection(): Collection<UserProfile> {
        return this.databaseService.database.collection(DATABASE_COLLECTION);
    }


    /**
     * Retourne un tableau qui contient un élément de type profil utilisateur à l'aide d'une adresse mail
     * sinon retourne un tableau vide
     *
     * @param username profil utilisateur
     */
    async getUserProfileByMail(userProfileEmailAddress: string): Promise<UserProfile[]> {
        return this.collection
            .find({ emailAddress: userProfileEmailAddress })
            .toArray()
            .then((userProfile: UserProfile[]) => {
                return userProfile;
            });
    }

    /**
     * Retourne un tableau qui contient un élément de type profil utilisateur à l'aide d'un nom d'utilisateur
     * sinon retourne un tableau vide
     *
     * @param username profil utilisateur
     */
    async getUserProfileByUsername(username: string): Promise<UserProfile[]> {
        return this.collection
            .find({ userName: username })
            .toArray()
            .then((userProfile: UserProfile[]) => {
                return userProfile;
            });
    }

    /**
     * Ajoute un profil utilisateur creer dans la base de donnes
     *
     * @param userProfile profil utilisateur
     */
    async addUserProfile(userProfile: UserProfile): Promise<void> {
        await this.collection.insertOne(userProfile);
    }

    /**
     * Met à jour le statut du profil utilisateur lors de la connexion
     *
     * @param userProfile profil utilisateur
     */
    async updateStatusToConnected(userProfile: UserProfile): Promise<void> {
        return this.collection.updateOne({ emailAddress: userProfile.emailAddress }, { $set: { isSigned: true } }).then();
    }

    /**
     * Met à jour le statut du profil utilisateur lors de la déconnexion
     *
     * @param userName nom d'utilisateur
     */
    async updateStatusToDisconnected(userName: string): Promise<void> {
        return this.collection.updateOne({ userName: userName }, { $set: { isSigned: false } }).then();
    }

    /**
     * Met à jour l'avatar du profil utilisateur
     *
     * @param userProfile profil utilisateur
     */
    async updateUserAvatarUrl(userProfile: UserProfile): Promise<void> {
        return this.collection.updateOne({ userName: userProfile.userName }, { $set: { avatarUrl: userProfile.avatarUrl } }).then();
    }


    /**
     * Met à jour le nom d'utilisateur du profil avec un 
     * nouveau nom d'utilisateur
     *
     * @param emailAddress mail de l'utilisateur
     * @param newUserName nouveau nom d'utilisateur
     */
    async updateUserName(emailAddress: string, newUserName: string): Promise<void> {
        
        return this.collection.updateOne({ emailAddress: emailAddress }, { $set: { userName: newUserName}}).then();
    }


    /**
     * Met à jour le nom d'utilisateur du profil avec un 
     * nouveau Url d'avatar
     *
     * @param emailAddress mail de l'utilisateur
     * @param newAvatarUrl nouveau Url d'avatar
     */
    async updateNewUserAvatarUrl(emailAddress: string, newAvatarUrl: string): Promise<void> {
        return this.collection.updateOne({ emailAddress: emailAddress }, { $set: { avatarUrl: newAvatarUrl}}).then();
    }


    /**
     * incrémente le nombre de parties jouées 
     *
     * @param userProfile profil utilisateur
     */
    async incrementGamePlayed(userName: string): Promise<void> {
        return this.collection.updateOne({ userName: userName}, {$inc: { gamePlayed : 1}}).then();
    }

    /**
     * incrémente le nombre de parties gagnées 
     *
     * @param userProfile profil utilisateur
     */
     async incrementGameWon(userName: string): Promise<void> {
        return this.collection.updateOne({ userName: userName}, {$inc: { gameWon : 1}}).then();
    }

    /**
     * incrémente le nombre de parties gagnées 
     *
     * @param userProfile profil utilisateur
     */
     async incrementGameLost(userName: string): Promise<void> {
        return this.collection.updateOne({ userName: userName}, {$inc: { gameLost : 1}}).then();
    }

    async getAveragePoints(userName: string): Promise<number> {
        const userProfile: UserProfile[] = await this.getUserProfileByUsername(userName);
        return userProfile[0].averagePoints as number;
        // return this.collection.findOne({userName: userName}, { projection: { averagePoints: 1, _id: 0 }}).then();
    }

    async getGamePlayed(userName: string): Promise<number> {
        const userProfile: UserProfile[] = await this.getUserProfileByUsername(userName);
        return userProfile[0].gamePlayed as number;
        // return this.collection.findOne({userName: userName}, { projection: { gamePlayed: 1, _id: 0 }}).then();
    }

    async getGameWon(userName: string): Promise<number> {
        const userProfile: UserProfile[] = await this.getUserProfileByUsername(userName);
        return userProfile[0].gameWon as number;
        // return this.collection.findOne({userName: userName}, { projection: { gameWon: 1, _id: 0 }}).then();
    }
    /**
     * met à jour la moyenne de points par partie
     *
     * @param userName mail de l'utilisateur
     * @param newPoints nouveau points
     */
    async updateAveragePoint(userName: string, newPoints: number): Promise<void> {
        console.log('updateAveragePoint call');
        const oldAveragePoints: number = await this.getAveragePoints(userName);
        const oldGamePlayed: number = await this.getGamePlayed(userName);
        const newAveragePoints: number = Math.floor(((oldAveragePoints * oldGamePlayed) + newPoints)/ (oldGamePlayed + 1));
        this.collection.updateOne({ userName: userName}, {$set: {averagePoints: newAveragePoints }});
        
    }

    async updateGrade(userName: string, grade: string): Promise<void> {
        await this.collection.updateOne({userName: userName}, {$set: { grade: grade} }).then();
    }

    async updateLevel(userName: string, level: string): Promise<void> {
        await this.collection.updateOne({userName: userName}, {$set: { level: level} }).then();
    }
    
    async updateGradeAfterGame(userName: string): Promise<void> {
        const gameWon: number = await this.getGameWon(userName);
        if(gameWon == 0) {
            await this.updateGrade(userName,Grade.NoGrade);
        } else if( gameWon >= 1 && gameWon <= 4)
        {
            await this.updateGrade(userName,Grade.Bronze);
        } else if( gameWon >= 5 && gameWon <= 9)
        {
            await this.updateGrade(userName,Grade.Silver);
        } else if( gameWon >= 10 && gameWon <= 14)
        {
            await this.updateGrade(userName,Grade.Gold);
        } else if( gameWon >= 15 && gameWon <= 24)
        {
            await this.updateGrade(userName,Grade.Platinum);
        } else if( gameWon >= 25)
        {
            await this.updateGrade(userName,Grade.Diamond);
        }
    }

    async updateLevelAfterGame(userName: string): Promise<void> {
        const gamePlayed: number = await this.getGamePlayed(userName);
        if(gamePlayed == 0) {
            await this.updateLevel(userName,Level.NoLevel);
        } else if( gamePlayed >= 1 && gamePlayed <= 4)
        {
            await this.updateLevel(userName,Level.Novice);
        } else if( gamePlayed >= 5 && gamePlayed <= 14)
        {
            await this.updateLevel(userName,Level.Casual);
        } else if( gamePlayed >= 15 && gamePlayed <= 24)
        {
            await this.updateLevel(userName,Level.Pro);
        } else if( gamePlayed >= 25)
        {
            await this.updateLevel(userName,Level.Master);
        }
    }

    async getAverageTime(userName: string): Promise<Duration> {
        const userProfile: UserProfile[] = await this.getUserProfileByUsername(userName);
        return userProfile[0].averageTime as Duration;
        // return this.collection.findOne({userName: userName}, { projection: { averageTime: 1, _id: 0 }}).then();
    }
    async updateAverageTime(userName: string, duration: Duration): Promise<void> {
        console.log("updateAverageTime call")
        const oldAverageTime: Duration = await this.getAverageTime(userName);
        const oldGamePlayed: number = await this.getGamePlayed(userName);
        const oldAverageTimeInSeconds = (oldAverageTime.minutes * 60) + oldAverageTime.seconds;
        const durationInSeconds = (duration.minutes * 60) + duration.seconds;
        const newAverageTimeInSeconds = Math.floor(((oldAverageTimeInSeconds * oldGamePlayed ) + durationInSeconds)/(oldGamePlayed + 1));
        let newAverageTime = {
            minutes: Math.floor(newAverageTimeInSeconds / 60),
            seconds: Math.floor(newAverageTimeInSeconds % 60),
        }
        this.collection.updateOne({ userName: userName}, {$set: {averageTime: newAverageTime }});

    }



}
