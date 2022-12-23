import { Component, Input, OnInit } from '@angular/core';

import { Message } from '@app/classes/chatbox/message';
@Component({
    selector: 'app-chatbox-message',
    templateUrl: './chatbox-message.component.html',
    styleUrls: ['./chatbox-message.component.scss'],
})
export class ChatboxMessageComponent implements OnInit {
    @Input() message: Message;
    messageContent: string;
    isGif: boolean;
    isFile: boolean;
    isText: boolean;
    ngOnInit(): void {
        // avoid lag
        if (this.message.content != this.messageContent) {
            this.messageContent = this.message.content;
            this.isGif = this.messageContent.includes('https://') && this.messageContent.includes('giphy.com');
            this.isFile = this.messageContent.includes('https://file.io/');
            this.isText = !this.isGif && !this.isFile;
        }
    }
}
