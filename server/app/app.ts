import { HttpException } from '@app/classes/http-exception/http.exception';
import { AdminController } from '@app/controllers/admin/admin.controller';
import { GameHistoryController } from '@app/controllers/game-history/game-history.controller';
import { ScoresController } from '@app/controllers/scores/scores.controller';
import * as cookieParser from 'cookie-parser';
import * as cors from 'cors';
import * as express from 'express';
import { StatusCodes } from 'http-status-codes';
import * as logger from 'morgan';
import 'reflect-metadata';
import * as swaggerJSDoc from 'swagger-jsdoc';
import * as swaggerUi from 'swagger-ui-express';
import { Service } from 'typedi';
import { UserAuthController } from './controllers/user/user-auth.controller';
import { UserInfoController } from './controllers/user/user-info.controller';

@Service()
export class Application {
    app: express.Application;

    private readonly internalError: number = StatusCodes.INTERNAL_SERVER_ERROR;
    private readonly swaggerOptions: swaggerJSDoc.Options;
    constructor(
        protected scoresController: ScoresController,
        protected gameHistoryController: GameHistoryController,
        protected adminController: AdminController,
        protected userAuthController: UserAuthController,
        protected userInfoController: UserInfoController,
    ) {
        this.app = express();

        this.swaggerOptions = {
            swaggerDefinition: {
                openapi: '3.0.0',
                info: {
                    title: 'Cadriciel Serveur',
                    version: '1.0.0',
                },
            },
            apis: ['**/*.ts'],
        };

        this.config();

        this.bindRoutes();
    }

    bindRoutes(): void {
        this.app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerJSDoc(this.swaggerOptions)));
        this.app.use('/api/scores', this.scoresController.router);
        this.app.use('/api/game-history', this.gameHistoryController.router);
        this.app.use('/api/admin', this.adminController.router);
        this.app.use('/api/auth', this.userAuthController.router);
        this.app.use('/api/user-info', this.userInfoController.router);
        this.errorHandling();
    }

    private config(): void {
        // Middlewares configuration
        this.app.use(logger('dev'));
        this.app.use(express.json());
        this.app.use(express.urlencoded({ extended: true }));
        this.app.use(cookieParser());
        this.app.use(cors());
    }

    private errorHandling(): void {
        // When previous handlers have not served a request: path wasn't found
        this.app.use((req: express.Request, res: express.Response, next: express.NextFunction) => {
            const err: HttpException = new HttpException('Not Found');
            next(err);
        });

        // development error handler
        // will print stacktrace
        if (this.app.get('env') === 'development') {
            this.app.use((err: HttpException, req: express.Request, res: express.Response) => {
                res.status(err.status || this.internalError);
                res.send({
                    message: err.message,
                    error: err,
                });
            });
        }

        // production error handler
        // no stacktraces leaked to user (in production env only)
        this.app.use((err: HttpException, req: express.Request, res: express.Response) => {
            res.status(err.status || this.internalError);
            res.send({
                message: err.message,
                error: {},
            });
        });
    }
}
