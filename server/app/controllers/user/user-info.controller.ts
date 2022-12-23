/* eslint-disable prettier/prettier */
/* eslint-disable no-console */
import { Connection } from '@app/classes/connection-history/connection-history';
import { DataPersistence } from '@app/classes/data-persistence/data-persistence';
import { GameStatus } from '@app/classes/game-played-history/game-played-history';
import { UserProfile } from '@app/classes/user-profile/user-profile';
import { UserProfileService } from '@app/database/user-profile/user-profile.service';
import { ConnectionHistoryHandler } from '@app/services/connection-history/connection-history-handler';
import { DataPersistenceHandler } from '@app/services/data-persistence/data-persistence-handler';
import { GamePlayedHistoryHandler } from '@app/services/game-played-history/game-played-history-handler';
import { UserProfileHandler } from '@app/services/user-profile/user-profile-handler';
import { Router } from 'express';
import * as Httpstatus from 'http-status-codes';
import { Service } from 'typedi';

@Service()
export class UserInfoController {
    router: Router;
    userList: string[] = [];

    constructor(
        private userProfileHandler: UserProfileHandler,
        private connectionHistoryHandler: ConnectionHistoryHandler,
        private gamePlayedHistory: GamePlayedHistoryHandler,
        private userProfileService: UserProfileService,
        private dataPersistenceHandler: DataPersistenceHandler,
    ) {
        this.configureRouter();
    }

    private configureRouter(): void {
        this.router = Router();

        // Update profil picture
        this.router.patch('/:userName/profil-picture', (req, res) => {
            const userProfile: UserProfile = {
                userName: req.params.userName,
                avatarUrl: req.body.avatarURL,
            };
            // update on mongoDB
            this.userProfileHandler.updateUserAvatarUrl(userProfile).then(() => {
                res.sendStatus(Httpstatus.StatusCodes.OK);
            });
        });

        this.router.post('/:userName/change-username', (req, res) => {
            const emailAddress: string = req.body.emailAddress;
            const newUsername: string = req.body.newUsername;
            this.userProfileHandler.updateNewUserName(emailAddress, newUsername).then((updateResponse) => {
                switch (updateResponse) {
                    case 'username-already-exist':
                        res.sendStatus(Httpstatus.StatusCodes.FORBIDDEN);
                        break;
                    default:
                        console.log('reponse du post');
                        console.log(updateResponse);
                        res.status(Httpstatus.StatusCodes.OK).send(updateResponse as UserProfile);
                        break;
                }
            });
        });

        this.router.post('/:userName/change-avatar', (req, res) => {
            const emailAddress: string = req.body.emailAddress;
            const newAvatarUrl: string = req.body.newAvatarUrl;
            this.userProfileHandler.updateUserNewAvatarUrl(emailAddress, newAvatarUrl).then((updateResponse) => {
                res.status(Httpstatus.StatusCodes.OK).send(updateResponse as UserProfile);
            });
        });

        this.router.post('/:userName/connection-history', (req, res) => {
            const emailAddress: string = req.body.emailAddress;
            this.connectionHistoryHandler.getAllConnectionHistory(emailAddress).then((connectionHistory: Connection[]) => {
                res.status(Httpstatus.StatusCodes.OK).send(connectionHistory);
            });
        });

        this.router.post('/:userName/game-played-history', (req, res) => {
            const emailAddress: string = req.body.emailAddress;
            this.gamePlayedHistory.getAllGameStatus(emailAddress).then((gameStatus: GameStatus[]) => {
                res.status(Httpstatus.StatusCodes.OK).send(gameStatus);
            });
        });

        this.router.post('/:userName/user-info-update', (req, res) => {
            const emailAddress: string = req.body.emailAddress;
            this.userProfileService.getUserProfileByMail(emailAddress).then((userProfile: UserProfile[]) => {
                res.status(Httpstatus.StatusCodes.OK).send(userProfile);
            });
        });

        this.router.post('/:userName/data-persistence', (req, res) => {
            const emailAddress: string = req.body.emailAddress;
            this.dataPersistenceHandler.getDataPersistence(emailAddress).then((dataPersistence: DataPersistence) => {
                res.status(Httpstatus.StatusCodes.OK).send(dataPersistence);
            });
        });

        this.router.post('/:userName/update-language', (req, res) => {
            const emailAddress: string = req.body.emailAddress;
            const language: string = req.body.language;
            this.dataPersistenceHandler.updateLanguage(emailAddress, language).then(() => {
                res.sendStatus(Httpstatus.StatusCodes.OK).send();
            });
        });

        this.router.post('/:userName/update-visual-theme', (req, res) => {
            const emailAddress: string = req.body.emailAddress;
            const visualTheme: string = req.body.visualTheme;
            this.dataPersistenceHandler.updateVisualTheme(emailAddress, visualTheme).then(() => {
                res.sendStatus(Httpstatus.StatusCodes.OK).send();
            });
        });
    }
}
