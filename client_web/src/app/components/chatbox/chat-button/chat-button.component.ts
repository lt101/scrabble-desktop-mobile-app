import { Component } from '@angular/core';

@Component({
    selector: 'app-chat-button',
    templateUrl: './chat-button.component.html',
    styleUrls: ['./chat-button.component.scss'],
})
export class ChatButtonComponent {
    openChat: boolean = false;

    toggleChat() {
        this.openChat = !this.openChat;
    }
}
