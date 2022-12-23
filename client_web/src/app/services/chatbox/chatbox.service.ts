import { Injectable } from '@angular/core';
import { Message } from '@app/classes/chatbox/message';
import * as CHATBOX from '@app/constants/chatbox';
import { CHATBOX_MESSAGE } from '@app/constants/events';
import { AuthService } from '@app/services/authentication/auth-service.service';
import { GameService } from '@app/services/game/game.service';
import { SocketManagerService } from '@app/services/socket-manager/socket-manager.service';
import { Observable, Subject } from 'rxjs';

@Injectable({
    providedIn: 'root',
})
export class ChatboxService {
    messagesSource = new Subject<Message>();

    constructor(
        private readonly socketManagerService: SocketManagerService,
        private readonly gameService: GameService,
        private readonly authService: AuthService,
    ) {
        this.socketManagerService.connect();
        this.socketManagerService.on(CHATBOX_MESSAGE, this.onMessage.bind(this));
    }

    /**
     * Retourne la classe CSS à appliquer au message en fonction de l'auteur
     *
     * @param playerId Identifiant du joueur
     * @returns Classe CSS à appliquer au message
     */
    getStyleFromAuthor(playerId: string): string {
        if (playerId === this.socketManagerService.getId()) return CHATBOX.MESSAGE_CLASS_BY_ME;
        else if (playerId === CHATBOX.SERVER_ID) return CHATBOX.MESSAGE_CLASS_BY_SERVER;
        else return CHATBOX.MESSAGE_CLASS_BY_OTHER_PLAYER;
    }

    /**
     * Retourne un observable sur les messages
     *
     * @returns Observable sur les messages
     */
    getMessages(): Observable<Message> {
        return this.messagesSource.asObservable();
    }

    /**
     * Traite la réception d'un nouveau message
     *
     * @param newMessage Nouveau message
     */
    onMessage(newMessage: Message): void {
        this.messagesSource.next({
            ...newMessage,
            cssClass: this.getStyleFromAuthor(newMessage.playerId),
        });
    }

    /**
     * Envoie un message vers le serveur
     *
     * @param content Contenu du message à envoyer
     */
    emitMessage(content: string, isGeneralScope?: boolean): void {
        if (this.socketManagerService.isSocketAlive()) {
            let scopedGameId: string | null;
            if (isGeneralScope === true) {
                scopedGameId = null;
            } else {
                if (!this.gameService.getId()) return;
                scopedGameId = this.gameService.getId();
            }
            const message: Message = {
                gameId: scopedGameId,
                playerId: this.socketManagerService.getId(),
                playerName: this.authService.userProfile.userName!,
                content,
            };
            this.socketManagerService.emit(CHATBOX_MESSAGE, message);
        }
    }
}
