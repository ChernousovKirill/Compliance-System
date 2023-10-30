import { LightningElement, api, track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getDocumentIdFromContentVersion from '@salesforce/apex/FileUploadController.getDocumentIdFromContentVersion';

export default class AttachmentVisibilityPanel extends NavigationMixin(LightningElement) {

    @api attachment;
    @api nameofsection;
    @api numberofuploadedfiles;
    @api recordid;
    @api showtypepicklist = false;
    @api isValueOther = false;
    @api specifiedTypeValue;

    @api optionsoftype;
    @api objectApiName;

    handleDeleteAttachment(event){
        const selectedEvent = new CustomEvent("deleterecord", {
            detail:{
                attachmentIdForDelete: event.target.dataset.id,
                nameOfSection: this.nameofsection
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    handleChangeType(event) {

        let valueOfType = event.detail.value;
    
        if (valueOfType == 'Other') {
            this.isValueOther = true;
        } else {
            this.isValueOther = false;
        }
    
        const selectedEvent = new CustomEvent("changetype", {
            detail:{
                idOfAttachment: event.target.dataset.id,
                valueOfType: valueOfType,
                isValueOther: this.isValueOther
            }
        });
        this.dispatchEvent(selectedEvent);
    }
    

    handleOtherTypeChange(event) {

        this.specifiedTypeValue = event.detail.value;

        const selectedEvent = new CustomEvent("changetype", {
            detail:{
                idOfAttachment: event.target.dataset.id,
                specifiedTypeValue: this.specifiedTypeValue,
                isValueOther: this.isValueOther
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