import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import handleUploadNewAttachment from '@salesforce/apex/FileUploadController.handleUploadNewAttachment';
import toastFailed from '@salesforce/label/c.toastFailedLabel';
import filesUploadSuccess from '@salesforce/label/c.fileUploadSuccessLabel';
import filesUploadFailed from '@salesforce/label/c.filesUploadFailedLabel';
import fileUploadLabel from '@salesforce/label/c.fileUploadLabel';

export default class FileUploadPanel extends LightningElement {

    @api recordid;
    @api typeofattachment;
    @api listofuploadedattachments = [];

    @track toastFailedLabel = toastFailed;
    @track filesUploadSuccessLabel = filesUploadSuccess;
    @track filesUploadFailedLabel = filesUploadFailed;
    @track fileUploadLabel = fileUploadLabel;

    handleUploadFinished(event) {
        let listOfDocumentIds = [];
        event.detail.files.forEach(file => {
            listOfDocumentIds.push(file.documentId);   
        });

        handleUploadNewAttachment({
            listOfAttachmentIds : listOfDocumentIds,
            recordId : this.recordid,
            typeOfAttachment: this.typeofattachment
        }).then((result) => {
            if (result) {
                let numberOfUploadFiles = event.detail.files.length;
                this.checkForSuccessfullyUploadedFiles(result, numberOfUploadFiles);
            }
            this.error = undefined;
        }).catch((error) => {
            this.error = error;
            console.log(error);
        });
    }

    checkForSuccessfullyUploadedFiles(result, numberOfUploadFiles){
        let numberOfSuccessfullyUploaded = result.length;
        this.numberofuploadedfiles += numberOfSuccessfullyUploaded;
            if (numberOfSuccessfullyUploaded != 0) {
                this.showNotification(numberOfSuccessfullyUploaded + ' ' + this.filesUploadSuccessLabel, 'Success');
                if(numberOfUploadFiles != numberOfSuccessfullyUploaded){
                    this.showNotification(this.filesUploadFailedLabel, 'error');
                }
                let listOfAttachments = JSON.parse(JSON.stringify(this.listofuploadedattachments));
                result.forEach(attachment => {
                    listOfAttachments.push(attachment);   
                });
                this.listofuploadedattachments = listOfAttachments;
                this.handleChange();
            } else {

                this.showNotification(this.filesUploadFailedLabel, 'error');
            }
    }

    showNotification(parameterMessage, parameterVariant) {
        const event = new ShowToastEvent({
            message : parameterMessage,
            variant : parameterVariant
        });
        this.dispatchEvent(event);
    }

    handleChange() {
        const selectedEvent = new CustomEvent("attachmentchange", {
            detail:{
                uploadedAttachmentsNumber: this.numberofuploadedfiles, listOfUploadedAttachments: this.listofuploadedattachments, nameOfSection: this.typeofattachment
            }
        });
        this.dispatchEvent(selectedEvent);
        this.listofuploadedattachments = [];
    }
}