/* eslint-disable prettier/prettier */
/* eslint-disable no-console */
import { UserProfile } from '@app/classes/user-profile/user-profile';
import { UserProfileHandler } from '@app/services/user-profile/user-profile-handler';
import { Router } from 'express';
import * as fs from 'fs';
import * as Httpstatus from 'http-status-codes';
import * as jwt from 'jsonwebtoken';
import { Service } from 'typedi';

const currentDirectory = process.cwd();
const RSA_PRIVATE_KEY = fs.readFileSync(currentDirectory + '/app/controllers/user/rsa-key/private.key');

@Service()
export class UserAuthController {
    router: Router;
    userList: string[] = [];

    constructor(private userProfileHandlerService: UserProfileHandler) {
        this.configureRouter();
    }

    private configureRouter(): void {
        this.router = Router();

        this.router.post('/register', async (req, res) => {
            const userProfile: UserProfile = req.body;
            console.log('user-auth.controller /register');
            const registerStatus: string = await this.userProfileHandlerService.registerUserProfile(userProfile);
            switch (registerStatus) {
                case 'email-taken':
                    res.status(Httpstatus.StatusCodes.CONFLICT);
                    break;
                case 'username-taken':
                    res.status(Httpstatus.StatusCodes.NOT_ACCEPTABLE);
                    break;
                case 'user-created':
                    res.status(Httpstatus.StatusCodes.CREATED);
                    break;
                default:
                    res.status(Httpstatus.StatusCodes.NOT_FOUND);
                    break;
            }

            res.json(userProfile);
        });

        this.router.post('/sign-in', (req, res) => {
            // const userProfil: UserProfile = req.body;
            const userProfile: UserProfile = {
                emailAddress: req.body.emailAddress,
                password: req.body.password,
            };
            const loginDate = new Date().toLocaleString();
            console.log('user-auth.controller /sign-in');
            console.log('login Date');
            console.log(loginDate);
            const status = 'login';

            this.userProfileHandlerService.signInUserProfile(userProfile, loginDate, status).then((signInResponse) => {
                switch (signInResponse) {
                    case 'user-already-connected':
                        res.sendStatus(Httpstatus.StatusCodes.FORBIDDEN);
                        break;
                    case 'user-incorrect-password':
                        res.sendStatus(Httpstatus.StatusCodes.UNAUTHORIZED);
                        break;
                    case 'user-not-exist':
                        res.sendStatus(Httpstatus.StatusCodes.NOT_FOUND);
                        break;
                    default:
                        const jwtBearerToken = this.generateJWT();
                        const newUserProfile = signInResponse as UserProfile;
                        res.status(Httpstatus.StatusCodes.OK)
                            .json({
                                idToken: jwtBearerToken,
                                expiresIn: 10800,
                                newUserProfile,
                            })
                            .send();
                        break;
                }
            });
        });

        this.router.patch('/:username/sign-out', (req, res) => {
            const userName = req.params.username;
            const emailAddress = req.body.emailAddress;
            const logoutDate = new Date().toLocaleString();
            const status = 'logout';
            this.userProfileHandlerService.signOutUserProfile(userName, emailAddress, logoutDate, status);
            res.sendStatus(Httpstatus.StatusCodes.OK);
        });
    }

    // Generates a JWT session token that expires in 10800s (3 hours)
    private generateJWT() {
        const token = jwt.sign({}, RSA_PRIVATE_KEY, {
            algorithm: 'RS256',
            expiresIn: 10800,
            subject: 'test',
        });
        return token;
    }
}
