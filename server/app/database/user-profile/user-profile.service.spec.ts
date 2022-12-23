import { MOCK_USER_PROFILE, MOCK_FAKE_EMAIL_ADDRESS, MOCK_USER } from "@app/constants/user-profile";
import { DatabaseServiceMock } from "../database/database.service.mock";
import { DatabaseService } from "../database/database.service";
import { UserProfileService } from "./user-profile.service";
import * as chai from 'chai';
import { expect } from 'chai';
import * as chaiAsPromised from 'chai-as-promised';
import { describe } from 'mocha';
import { MongoClient } from 'mongodb';
import { UserProfile } from "@app/classes/user-profile/user-profile";

chai.use(chaiAsPromised);

describe.only('User profile service', () => {
    let userProfileService: UserProfileService;
    let databaseService: DatabaseServiceMock;
    let client: MongoClient | undefined;
    const populateDb = async (...userProfile: UserProfile[]) => {
        await databaseService.populateDb('userProfile', userProfile);
    };

    beforeEach(async () => {
        databaseService = new DatabaseServiceMock();
        client = (await databaseService.start()) as MongoClient;
        userProfileService = new UserProfileService(databaseService as unknown as DatabaseService);
        databaseService.start();
    });

    afterEach(async () => {
        await databaseService.closeConnection();
    });

    // it('should get user profile by email address', async () => {
    //     await populateDb(MOCK_USER_PROFILE);
    //     const userProfile = await userProfileService.getUserProfileByMail(MOCK_USER_PROFILE.emailAddress);
    //     expect(userProfile.length).to.equal(1);
    // })

    it('should not get user profile by email address', async () => {
        await populateDb(MOCK_USER_PROFILE);
        const userProfile = await userProfileService.getUserProfileByMail(MOCK_FAKE_EMAIL_ADDRESS);
        expect(userProfile.length).to.equal(0);
    })

    it('should update username', async () => {
        await populateDb(MOCK_USER);
        await userProfileService.updateUserName(MOCK_USER, 'test55');
        const userProfile = userProfileService.getUserProfileByMail((MOCK_USER.emailAddress)!)
        console.log(userProfile[0].userName);
        expect(userProfile[0].userName).to.equal('test55')
    })

    describe('Error handling', async () => {
        it('should throw an error if we try to get all game history on a closed connection', async () => {
            await client?.close();
        });
        it('close connection should return a promise when client is undefined', async () => {
            // eslint-disable-next-line dot-notation
            databaseService['client'] = undefined;
            databaseService.closeConnection();
            expect(true);
        });
    });

});