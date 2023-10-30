import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveLWCLog from '@salesforce/apex/LogService.saveLWCLog';
import getValuesForRecordDetailesPage from '@salesforce/apex/ApplicationFormService.getValuesForRecordDetailesPage';
import updateRecordFromDetailPage from '@salesforce/apex/ApplicationFormService.updateRecordFromDetailPage';

import cancelButtonLabel from '@salesforce/label/c.cancelButton';
import saveButtonLabel from '@salesforce/label/c.saveButtonLabel';
import labelOfErrorShowToast from '@salesforce/label/c.Something_went_wrong';
import labelOfSuccessfullySavedForm from '@salesforce/label/c.labelOfSuccessfullySavedRecord';

export default class UboDetailPage extends LightningElement {
    @track sections;
    @track listOfSowSofDocuments;
    @track listOfIndividualDocuments;
    @track isSaveButtonAvailable = false;
    @track updatedUBOFields = [];
    @track updatedDocumentFields = [];
    @track documentsForInsert = [];

    @api recordId;
    @api objectApiName;
    @api isHideDocumentType = false;
    @api labelOfCancelButtom = cancelButtonLabel;
    @api labelOfSaveButton = saveButtonLabel;
    @api typeOfForm = 'UBO';

    @api optionsOfStatus = [
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

    connectedCallback() {
        this.getValuesForDetails();
    }

    getValuesForDetails() {
        getValuesForRecordDetailesPage({
            recordId: this.recordId,
            typeOfForm: this.typeOfForm
        }).then((result) => {
            if (result) {
                const {sections, listOfSowSofDocuments, listOfIndividualDocuments} = result;
                this.sections = sections;
                this.listOfSowSofDocuments = listOfSowSofDocuments;
                this.listOfIndividualDocuments = listOfIndividualDocuments;

                this.sections.forEach((section) => {
                    section.fields.forEach((field) => {
                        if(field.apiNameOfField == 'DOT_Government__c') {
                            this.listOfIndividualDocuments.forEach((document) => {
                                if(document.label == 'Document of Trust') {
                                    if(field.defaultValue == 'Yes') {
                                        document.isHide = false;
                                    } else {
                                        document.isHide = true;
                                    }
                                }
                            });
                        }
                    });
                });
            }
            this.error = undefined;
        }).catch((error) => {
            this.error = error;
            saveLWCLog({ id: this.recordId, description: JSON.stringify(this.error) });
        });
    }

    updateUBOFromDetailsPage() {

        const uboFieldsForUpdate = {};
        this.updatedUBOFields.forEach((field) => {
            uboFieldsForUpdate[field.apiNameOfField] = field.value;
        });
        this.uboFieldsForUpdate = uboFieldsForUpdate;
    
        updateRecordFromDetailPage({ recordId: this.recordId,
                                apiNameOfObject : this.objectApiName,
                                recordFieldsForUpdate: this.uboFieldsForUpdate,
                                listOfDocumentsForInsert: this.documentsForInsert,
                                listOfUpdatedDocumentFields: this.updatedDocumentFields })
            .then(() => {
                this.showToast('', labelOfSuccessfullySavedForm, 'Success');
                window.location.reload();
            })
            .catch((error) => {
                this.showToast('Error', labelOfErrorShowToast, 'Error');
            saveLWCLog({ id : this.recordid,
              description: JSON.stringify(error)})
            });
        
    }

    handleSaveUBOChanges() {
        this.updateUBOFromDetailsPage();
    }

    handleSaveDocument(event) {

        let documentForInsert = event.detail.documentForInsert;
        this.isSaveButtonAvailable = event.detail.isSaveButtonAvailable;
        this.documentsForInsert = [...this.documentsForInsert, documentForInsert];

    }

    handleChangeUBOFields(event) {

        this.isSaveButtonAvailable = event.detail.isSaveButtonAvailable;
        let nameOfField = event.detail.apiNameOfField;
        let value = event.detail.value;

        if(nameOfField == 'DOT_Government__c') {
            this.listOfIndividualDocuments.forEach((document) => {
                if(document.label == 'Document of Trust') {
                    if(value == 'Yes') {
                        document.isHide = false;
                    } else {
                        document.isHide = true;
                    }
                }
            });
        }
        
        let existingField = this.updatedUBOFields.find(function(field) {
            return field.apiNameOfField === nameOfField;
        });

        if (existingField) {
            existingField.value = value;
        } else {
            this.updatedUBOFields.push({
                apiNameOfField: nameOfField,
                value: value
            });
        }
        console.log('this.updatedUBOFields ' + JSON.stringify(this.updatedUBOFields));
    }

    handleChangeDocumentValue(event) {
        this.isSaveButtonAvailable = event.detail.isSaveButtonAvailable;

        let fieldApi = event.detail.fieldApi;
        let recordId = event.detail.recordId;
        let updatedValue = event.detail.updatedValue;

        let record = this.updatedDocumentFields.find(item => item.recordId === recordId);
        if (!record) {
            record = { recordId: recordId, fieldsToUpdate: [] };
            this.updatedDocumentFields.push(record);
        }
    
        record.fieldsToUpdate.push({ fieldApi: fieldApi, updatedValue: updatedValue });

    }

    handleCancelEditForm() {
        this.isSaveButtonAvailable = false;
        window.location.reload();
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