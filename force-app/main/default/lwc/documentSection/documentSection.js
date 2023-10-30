import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import addDocumentLabel from '@salesforce/label/c.addDocumentLabel';
import cancelButtonLabel from '@salesforce/label/c.cancelButton';
import saveButtonLabel from '@salesforce/label/c.saveButtonLabel';

export default class DocumentSection extends NavigationMixin(LightningElement) {

    @track isSaveButtonAvailable = false;
    @track documentFieldsForInsert = [];
    @track documentsForDisplay = [];
    @track typeOfDocument;

    @api documents;
    @api section;
    @api ishidedocumenttype;
    @api labelfordocuments;
    @api showNewDocumentModalWindow = false;
    @api optionsOfStatus = [
        { value: 'Requested', label: 'Requested' },
        { value: 'Pending', label: 'Pending' },
        { value: 'Verified', label: 'Verified' },
        { value: 'Postponed', label: 'Postponed' },
        { value: 'Rejected', label: 'Rejected' },
        { value: 'Not Applicable', label: 'Not Applicable' },
        { value: 'Not Available', label: 'Not Available' }
    ];

    @api optionsOfDocument = [
        { value: 'Copy', label: 'Copy' },
        { value: 'Excerpt', label: 'Excerpt' },
        { value: 'Certified', label: 'Certified' },
        { value: 'Apostilled', label: 'Apostilled' },
        { value: 'N/A', label: 'N/A' }
    ];

    @api optionsOfType = [
        { value: 'Individual', label: 'Individual' },
        { value: 'Corporate', label: 'Corporate' },
        { value: 'SOW/SOF', label: 'SOW/SOF' }
    ];

    @api labelOfAddDocumentButton = addDocumentLabel;
    @api labelOfCancelButtom = cancelButtonLabel;
    @api labelOfSaveButton = saveButtonLabel;
  
    get isDocumentsNotEmpty() {
        return this.documents && this.documents.length > 0;
    }

    connectedCallback(){
        this.documentsForDisplay = this.documents;
    }

    handleDocumentChange(event){
        this.isSaveButtonAvailable = true;
        let idOdRecord = event.target.dataset.id;
        let valueOfField = event.target.value;
        let apiNameOfField = event.target.dataset.fieldapi;

        const selectedEvent = new CustomEvent("changedocument", {
            detail:{
                isSaveButtonAvailable: this.isSaveButtonAvailable,
                fieldApi: apiNameOfField,
                recordId: idOdRecord,
                updatedValue: valueOfField
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    handleDocumentNewValues(event) {
        let apiNameOfField = event.target.dataset.fieldapi;
        let valueOfField = event.detail.value;

        let existingField = this.documentFieldsForInsert.find(function(field) {
            return field.apiNameOfField === apiNameOfField;
        });

        if (existingField) {
            existingField.value = valueOfField;
        } else {
            this.documentFieldsForInsert.push({
                apiNameOfField: apiNameOfField,
                value: valueOfField
            });
        }
    }

    handleSaveDocument() {
        let newDocument = {};
        this.documentFieldsForInsert.forEach((field) => {
            if(field.apiNameOfField == 'Name') {
                newDocument.label = field.value;
            }
            if(field.apiNameOfField == 'Status__c') {
                newDocument.status = field.value;
            }

            if(this.typeOfDocument == 'SOW/SOF') {
                newDocument.type = this.typeOfDocument;
            } else if(this.labelfordocuments == 'Individual Documents' || this.labelfordocuments == 'Documents') {
                newDocument.type = 'Individual';
            } else if(this.labelfordocuments == 'Corporate Documents') {
                newDocument.type = 'Corporate';
            }
        });

        if (!this.documentsForDisplay.some(doc => doc.label === newDocument.label)) {
            this.documentsForDisplay = [...this.documentsForDisplay, newDocument];
        } else {
            this.showToast('Error', 'Document name must be unique!', 'Error');
        }

        this.showNewDocumentModalWindow = false;

        const selectedEvent = new CustomEvent("savedocument", {
            detail:{
                isSaveButtonAvailable: true,
                documentForInsert: newDocument
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    handleShowNewDocumentModalWindow(event) {
        this.showNewDocumentModalWindow = true;
        this.typeOfDocument =event.target.dataset.id;
    }

    handleCloseNewDocumentModalWindow() {
        this.showNewDocumentModalWindow = false;
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