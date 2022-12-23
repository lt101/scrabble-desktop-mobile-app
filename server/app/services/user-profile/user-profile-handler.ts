import { Duration } from '@app/classes/game-history/duration';
import { UserProfile } from '@app/classes/user-profile/user-profile';
import { UserProfileService } from '@app/database/user-profile/user-profile.service';
import { ConnectionHistoryHandler } from '@app/services/connection-history/connection-history-handler';
import 'reflect-metadata';
import { Service } from 'typedi';
import { DataPersistenceHandler } from '../data-persistence/data-persistence-handler';
import { GamePlayedHistoryHandler } from '../game-played-history/game-played-history-handler';

@Service()
export class UserProfileHandler {
    constructor(
        private userProfileService: UserProfileService,
        private gamePlayedHistoryHandler: GamePlayedHistoryHandler,
        private connectionHistoryHandler: ConnectionHistoryHandler,
        private dataPersistenceHandler: DataPersistenceHandler,
    ) {}

    createUserProfile(user: UserProfile): UserProfile {
        if (user.avatarUrl === undefined) {
            user.avatarUrl =
                'https://firebasestorage.googleapis.com/v0/b/projet3-equipe106.appspot.com/o/default%2F115-1150152_default-profile-picture-avatar-png-green.png?alt=media&token=6ebaba8c-8178-429c-8a25-ef2255bb90e9';
        }
        const userProfil: UserProfile = {
            emailAddress: user.emailAddress,
            password: user.password,
            userName: user.userName,
            isSigned: false,
            avatarUrl: user.avatarUrl,
            grade: 'Pas de grade',
            level: 'Pas de niveau',
            gamePlayed: 0,
            gameWon: 0,
            gameLost: 0,
            averagePoints: 0,
            averageTime: { minutes: 0, seconds: 0 },
        };
        return userProfil;
    }

    async registerUserProfile(userProfile: UserProfile): Promise<string> {
        const userByEmail: UserProfile[] = await this.userProfileService.getUserProfileByMail(userProfile.emailAddress as string);
        const userByUsername: UserProfile[] = await this.userProfileService.getUserProfileByUsername(userProfile.userName as string);
        if (userByEmail.length !== 0) {
            return 'email-taken';
        }
        if (userByUsername.length !== 0) {
            return 'username-taken';
        }
        await this.userProfileService.addUserProfile(this.createUserProfile(userProfile));
        // initialise un objet de connection history dans la base de donnees
        await this.connectionHistoryHandler.initializeConnectionHistory(userProfile.emailAddress as string);
        // initialise un objet de played history dans la base de donnees
        await this.gamePlayedHistoryHandler.initializeGamePlayedHistory(userProfile.emailAddress as string);
        // initialise un objet de data persistence dans la base de donnees
        await this.dataPersistenceHandler.initializeDataPersistence(userProfile.emailAddress as string);

        return 'user-created';
    }

    async signInUserProfile(userProfile: UserProfile, loginDate: string, status: string): Promise<string | UserProfile> {
        // check if the profile exist
        const userByEmail: UserProfile[] = await this.userProfileService.getUserProfileByMail(userProfile.emailAddress as string);
        if (userByEmail.length != 0) {
            if (userProfile.password === userByEmail[0].password) {
                if (userByEmail[0].isSigned === true) {
                    return 'user-already-connected';
                }
                await this.userProfileService.updateStatusToConnected(userProfile);
                // Ajoute le log de la connexion
                await this.connectionHistoryHandler.addLogConnection(userProfile.emailAddress as string, loginDate, status);
                return userByEmail[0];
            } else {
                return 'user-incorrect-password';
            }
        } else {
            return 'user-not-exist';
        }
    }

    async signOutUserProfile(username: string, emailAddress: string, logoutDate: string, status: string): Promise<void> {
        await this.userProfileService.updateStatusToDisconnected(username);
        await this.connectionHistoryHandler.addLogConnection(emailAddress, logoutDate, status);
    }

    async updateUserAvatarUrl(userProfile: UserProfile): Promise<void> {
        await this.userProfileService.updateUserAvatarUrl(userProfile);
    }

    async updateNewUserName(emailAddress: string, newUserName: string): Promise<string | UserProfile> {
        const userByUsername: UserProfile[] = await this.userProfileService.getUserProfileByUsername(newUserName);
        if (userByUsername.length != 0) {
            return 'username-already-exist';
        } else {
            await this.userProfileService.updateUserName(emailAddress, newUserName);
            const userByEmail: UserProfile[] = await this.userProfileService.getUserProfileByMail(emailAddress);
            return userByEmail[0];
        }
    }

    async updateUserNewAvatarUrl(emailAddress: string, newAvatarUrl: string): Promise<UserProfile> {
        await this.userProfileService.updateNewUserAvatarUrl(emailAddress, newAvatarUrl);
        const userByEmail: UserProfile[] = await this.userProfileService.getUserProfileByMail(emailAddress);
        return userByEmail[0];
    }

    async endGame(userName: string, winner: boolean, points: number, duration: Duration, startDate: Date, endDate: Date) {
        console.log('user-profile-handler.ts');
        await this.gamePlayedHistoryHandler.addGamePlayed(userName, startDate, endDate, winner);
        await this.userProfileService.updateAverageTime(userName, duration);
        await this.userProfileService.updateAveragePoint(userName, points);
        await this.userProfileService.incrementGamePlayed(userName);
        if (winner) {
            await this.userProfileService.incrementGameWon(userName);
        } else {
            await this.userProfileService.incrementGameLost(userName);
        }
        await this.userProfileService.updateGradeAfterGame(userName);
        await this.userProfileService.updateLevelAfterGame(userName);
    }

    async getSidebarUserStats(usernames: string[]): Promise<UserProfile[]> {
        const sidebarUserInfo: UserProfile[] = [];
        for (let username of usernames) {
            let elements: UserProfile[] = await this.userProfileService.getUserProfileByUsername(username);
            sidebarUserInfo.push(elements[0]);
        }
        console.log('getSideBarUserState');
        console.log(sidebarUserInfo);
        console.log('fin du print de la methode des handler');
        return sidebarUserInfo;
    }
}
