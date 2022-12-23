import { Component, Input } from '@angular/core';
import { COMPONENT } from '@app/classes/control/component';
import { INPUT_ENTER_KEY, MESSAGE_DEFAULT_VALUE, MESSAGE_MAX_LENGTH, MESSAGE_MIN_LENGTH } from '@app/constants/chatbox';
import { ChatboxService } from '@app/services/chatbox/chatbox.service';
import { FileUploadService } from '@app/services/file-upload/file-upload.service';
import { KeyboardHandlerService } from '@app/services/keyboard/keyboard-handler.service';
const Giphy = require('giphy-api')('2cmgIryx9Je3HmroijdaCJd2P6UAy17x');
@Component({
    selector: 'app-chatbox-input',
    templateUrl: './chatbox-input.component.html',
    styleUrls: ['./chatbox-input.component.scss'],
})
export class ChatboxInputComponent {
    message: string;
    messageMinLength: number;
    messageMaxLength: number;
    isEmojiPickerVisible: boolean;
    isGifSearchVisible = false;
    giphySearchTerm = '';
    giphyResults: any[] = [];
    @Input() isGeneralScope: boolean = true;

    // file upload
    shortLink: string = '';
    file: File; // Variable to store file
    isUploadVisible: boolean = false;

    constructor(
        private readonly chatboxService: ChatboxService,
        private readonly keyboardHandlerService: KeyboardHandlerService,
        private fileUploadService: FileUploadService,
    ) {
        this.keyboardHandlerService.getCurrentController().subscribe(this.handleNewController.bind(this));
        this.message = MESSAGE_DEFAULT_VALUE;
        this.messageMinLength = MESSAGE_MIN_LENGTH;
        this.messageMaxLength = MESSAGE_MAX_LENGTH;
    }

    public addEmoji(event: any) {
        this.message = `${this.message}${event.emoji.native}`;
        this.isEmojiPickerVisible = false;
    }

    searchGiphy() {
        const searchTerm = this.giphySearchTerm;
        Giphy.search(searchTerm)
            .then((res: any) => {
                console.log(res);
                this.giphyResults = res.data;
            })
            .catch(console.error);
    }

    toggleEmojiPicker() {
        this.isEmojiPickerVisible = !this.isEmojiPickerVisible;
        this.isGifSearchVisible = false;
        this.isUploadVisible = false;
    }

    toggleGiphySearch() {
        this.isGifSearchVisible = !this.isGifSearchVisible;
        this.isEmojiPickerVisible = false;
        this.isUploadVisible = false;
    }

    /**
     * Réinitialise le champ de saisie de la boîte de communication
     */
    resetMessage(): void {
        this.message = MESSAGE_DEFAULT_VALUE;
    }
    /**
     * Réinitialise la chatbox si il ya un nouveau composant qui a le controle
     *
     * @param component Nouveau composant qui a le contrôle
     */
    handleNewController(component: COMPONENT) {
        if (component !== COMPONENT.CHATBOX) {
            this.resetMessage();
        }
    }

    /**
     * Gère l'événement de l'appuie sur la touche entrée
     *
     * @param event Évènement de clavier
     */
    handleKeyPressEvent(event: KeyboardEvent): void {
        if (event.key === INPUT_ENTER_KEY) this.emitMessage();
    }
    handleClick(event: MouseEvent) {
        this.keyboardHandlerService.takeControl(COMPONENT.CHATBOX);
        event.stopPropagation();
    }

    /**
     * Envoie le message saisi
     */
    emitMessage(): void {
        if (MESSAGE_MIN_LENGTH <= this.message.length && this.message.length <= MESSAGE_MAX_LENGTH) {
            this.chatboxService.emitMessage(this.message, this.isGeneralScope);
            this.resetMessage();
        }
    }

    /**
     * Envoie le message saisi
     */
    emitGif(gifURL: string): void {
        this.chatboxService.emitMessage(gifURL, this.isGeneralScope);
        this.isGifSearchVisible = false;
    }

    // On file Select
    onChange(event: any) {
        this.file = event.target.files[0];
    }

    // OnClick of button Upload
    onUpload() {
        console.log(this.file);
        if (this.file) {
            this.fileUploadService.upload(this.file).subscribe((event: any) => {
                if (typeof event === 'object') {
                    // Short link via api response
                    console.log(event);
                    this.shortLink = event.link;
                    this.chatboxService.emitMessage(this.shortLink, this.isGeneralScope);
                    this.toggleUploadContainer();
                }
            });
        }
    }

    toggleUploadContainer() {
        this.isUploadVisible = !this.isUploadVisible;
        this.isGifSearchVisible = false;
        this.isEmojiPickerVisible = false;
    }
}
