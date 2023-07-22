import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getDocumentIdFromContentVersion from '@salesforce/apex/FileUploadController.getDocumentIdFromContentVersion';

export default class AttachmentVisibilityPanel extends NavigationMixin(LightningElement) {

    @api attachment;
    @api nameofsection;
    @api numberofuploadedfiles;

    handleDeleteAttachment(event){
        const selectedEvent = new CustomEvent("deleterecord", {
            detail:{
                attachmentIdForDelete: event.target.dataset.id,
                nameOfSection: this.nameofsection
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    previewFile(event){
        getDocumentIdFromContentVersion({
            contentVersionId : event.currentTarget.dataset.id
        }).then((result) => {
            if(result){
                console.log('result ' + result);
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'filePreview'
                    },
                    state : {
                        selectedRecordId: result
                    }
                });
            }
        }).catch((error) => {
            console.log(error);
        });
    }
}