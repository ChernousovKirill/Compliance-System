import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import numberOfAttachmentLabel from '@salesforce/label/c.numberOfAttachmentLabel';
import labelOfAttachment from '@salesforce/label/c.labelOfAttachment';
import getUploadedAttachments from '@salesforce/apex/FileUploadController.getUploadedAttachments';
import deleteAttachment from '@salesforce/apex/FileUploadController.deleteAttachment';
import documentWasDeletedLabel from '@salesforce/label/c.documentWasDeletedLabel';

export default class AttachmentEditUploadPanel extends LightningElement {

    @api recordId;
    @api objectApiName;
    @api labelOfFiles = numberOfAttachmentLabel;
    @api labelOfAttachments = labelOfAttachment;

    @track numberofuploadedfiles = 0;
    @track listofuploadedattachments;
    @track showFileUploadModalWindow = false;

    connectedCallback() {
        this.getUploadedAttachmentsByRecordId();
    }

    getUploadedAttachmentsByRecordId() {
        getUploadedAttachments({
            recordId : this.recordId
        }).then((result) => {
            if(result){
                this.numberofuploadedfiles += result.length;
                this.listofuploadedattachments = JSON.parse(JSON.stringify(result));
            }
            this.error = undefined;
        }).catch((error) => {
            this.error = error;
            console.log(error);
        });
    }

    deleteAttachment(event) {
        deleteAttachment({
            idOfContentDocument: event.detail.attachmentIdForDelete
        }).then(() => {
            this.showToast('', documentWasDeletedLabel, 'Success');
            let listOfAttachments = JSON.parse(JSON.stringify(this.listofuploadedattachments));
            listOfAttachments.forEach(element => {
                if (element.contentDocumentId == event.detail.attachmentIdForDelete) {
                    listOfAttachments.splice(listOfAttachments.indexOf(element), 1);
                    listOfAttachments.slice();
                }
            });
            this.listofuploadedattachments = listOfAttachments;
            this.numberofuploadedfiles -= 1;

        }).catch((error) => {
            console.error(error);
        });
    }

    openFileUploadModalWindow(){
        this.showFileUploadModalWindow = true;
        this.labelofmodalwindow = 'Upload File';
    }

    handleClose(event) {
        const showModalWindow = event.detail;
        this.
        showFileUploadModalWindow = showModalWindow;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

}