import { Component, ElementRef, Input, OnChanges, OnInit, SimpleChanges, ViewChild } from '@angular/core';
import { Message } from '@app/classes/chatbox/message';

@Component({
    selector: 'app-chatbox-messages',
    templateUrl: './chatbox-messages.component.html',
    styleUrls: ['./chatbox-messages.component.scss'],
})
export class ChatboxMessagesComponent implements OnInit, OnChanges {
    ngOnChanges(changes: SimpleChanges): void {
        if (this.previousMsgCount !== changes.messageCount.currentValue) {
            this.previousMsgCount = changes.messageCount.currentValue;
            this.scrollToBottom();
        }
    }
    @Input() messages: Message[];
    @Input() messageCount: number;
    previousMsgCount: number;
    @ViewChild('scroll') scroll: ElementRef<HTMLDivElement>;

    ngOnInit() {
        this.previousMsgCount = 0;
        this.scrollToBottom();
    }

    scrollToBottom(): void {
        try {
            if (this.messageCount) this.scroll.nativeElement.scrollTop = window.innerHeight;
        } catch (err) {}
    }
    /**
     * Scroll vers le bas de la zone de messages lors de la réception d'un nouveau message
     */
    // ngOnChanges(changes: SimpleChanges) {
    //     if (this.scroll) this.scroll.nativeElement.scrollTop = this.scroll.nativeElement.scrollHeight;
    // }
}
