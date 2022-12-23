import { Component, OnInit } from '@angular/core';
import { MatCheckboxChange } from '@angular/material/checkbox';
import { Message } from '@app/classes/chatbox/message';
import * as EVENT from '@app/constants/events';
import { ChatboxService } from '@app/services/chatbox/chatbox.service';
import { SocketManagerService } from '@app/services/socket-manager/socket-manager.service';
var leoProfanity = require('leo-profanity');
var frenchBadwordsList = require('french-badwords-list');

@Component({
    selector: 'app-chatbox',
    templateUrl: './chatbox.component.html',
    styleUrls: ['./chatbox.component.scss'],
})
export class ChatboxComponent implements OnInit {
    messagesGeneral: Message[];
    messagesGame: Message[];

    messageCount: number;
    censorship: boolean = false;
    isGeneral: boolean = true;
    gameId: string;

    constructor(private readonly chatboxService: ChatboxService, private readonly socketManagerService: SocketManagerService) {
        this.messagesGeneral = [];
        this.messagesGame = [];

        this.messageCount = 0;
        leoProfanity.add(frenchBadwordsList.array); // insert if language is french
        this.socketManagerService.on(EVENT.ROOM_GAME_STARTED, (informations: { gameId: string; timer: number }) => {
            this.gameId = informations.gameId;
        });
    }

    ngOnInit(): void {
        this.handleMessages();
    }

    toggleCensorship(ob: MatCheckboxChange) {
        this.censorship = ob.checked;
    }

    toggleScope(isGeneral: boolean): void {
        this.isGeneral = isGeneral;
    }

    /**
     * Gère la réception de nouveaux messages
     */
    private handleMessages(): void {
        this.chatboxService.getMessages().subscribe((newMessage: Message) => {
            if (leoProfanity.check(newMessage.content) && this.censorship) {
                newMessage.content = leoProfanity.clean(newMessage.content);
            }
            if (newMessage.gameId) this.messagesGame.push(newMessage);
            else this.messagesGeneral.push(newMessage);

            this.messageCount++;
        });
    }
}
