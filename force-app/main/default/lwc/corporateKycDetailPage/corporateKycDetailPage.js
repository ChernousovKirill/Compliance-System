import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveLWCLog from '@salesforce/apex/LogService.saveLWCLog';
import getValuesForRecordDetailesPage from '@salesforce/apex/ApplicationFormService.getValuesForRecordDetailesPage';
import updateRecordFromDetailPage from '@salesforce/apex/ApplicationFormService.updateRecordFromDetailPage';

import cancelButtonLabel from '@salesforce/label/c.cancelButton';
import saveButtonLabel from '@salesforce/label/c.saveButtonLabel';
import labelOfErrorShowToast from '@salesforce/label/c.Something_went_wrong';
import labelOfSuccessfullySavedForm from '@salesforce/label/c.labelOfSuccessfullySavedRecord';

export default class CorporateKycDetailPage extends LightningElement {

    @track sections;
    @track listOfDocuments;
    @track listOfGovernmentRecords;
    @track fieldsWithIndividualVisibilityType;
    @track fieldsWithCorporateVisibilityType;
    @track updatedDocumentFields = [];
    @track updatedRecordFields = [];
    @track documentsForInsert = [];

    @track showIndividualFields = false;
    @track showCorporateFields = false;
    @track isSaveButtonAvailable = false;

    @api recordId;
    @api objectApiName;
    @api isHideDocumentType = false;
    @api typeOfForm = 'Corporate KYC';
    @api labelOfCancelButtom = cancelButtonLabel;
    @api labelOfSaveButton = saveButtonLabel;

    connectedCallback() {
        this.getValuesForDetails();
    }

    getValuesForDetails() {
        getValuesForRecordDetailesPage({
            recordId : this.recordId,
            typeOfForm : this.typeOfForm
        }).then((result) => {
            if (result) {
                const {sections, listOfDocuments, fieldsWithIndividualVisibilityType, fieldsWithCorporateVisibilityType, listOfGovernmentRecords} = result;
                this.sections = sections;
                this.fieldsWithIndividualVisibilityType = fieldsWithIndividualVisibilityType;
                this.fieldsWithCorporateVisibilityType = fieldsWithCorporateVisibilityType;
                this.listOfDocuments = listOfDocuments;
            }

            this.sections.forEach((section) => {
                section.fields.forEach((field) => {
                    if (field.apiNameOfField == 'Type_Government__c') {
                        if(field.defaultValue == 'Individual') {
                            section.fields.push(...this.fieldsWithIndividualVisibilityType);
                        } else if(field.defaultValue == 'Corporate') {
                            section.fields.push(...this.fieldsWithCorporateVisibilityType);
                        }
                    }
                });
            });

            this.sections.forEach((section) => {
                section.fields.forEach((field) => {
                    if(field.apiNameOfField == 'DOT_Government__c') {
                        this.listOfDocuments.forEach((document) => {
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

            this.error = undefined;
        }).catch((error) => {
            this.error = error;
            saveLWCLog({ id: this.recordId, description: JSON.stringify(this.error) });
        });
    }

    updateRecord() {
        const recordFieldsForUpdate = {};
        this.updatedRecordFields.forEach((field) => {
            recordFieldsForUpdate[field.apiNameOfField] = field.value;
        });
        this.recordFieldsForUpdate = recordFieldsForUpdate;

        updateRecordFromDetailPage({ recordId: this.recordId,
                                apiNameOfObject : this.objectApiName,
                                recordFieldsForUpdate: this.recordFieldsForUpdate,
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

    handleCorporateKycFieldChange(event) {

        this.isSaveButtonAvailable = event.detail.isSaveButtonAvailable;
        let nameOfField = event.detail.apiNameOfField;
        let valueOfField = event.detail.value;

        if (nameOfField === 'Type_Government__c') {
            let fieldsToAdd = [];
            let fieldsToRemove = [];
    
            this.sections.forEach((section) => {
                section.fields.forEach((field) => {
                    if (field.apiNameOfField == 'Type_Government__c') {
                        if (valueOfField == 'Individual') {
                            fieldsToAdd.push(...this.fieldsWithIndividualVisibilityType);
                            fieldsToRemove.push(...this.fieldsWithCorporateVisibilityType);
                        } else if (valueOfField == 'Corporate') {
                            fieldsToAdd.push(...this.fieldsWithCorporateVisibilityType);
                            fieldsToRemove.push(...this.fieldsWithIndividualVisibilityType);
                        } else {
                            fieldsToRemove.push(...this.fieldsWithIndividualVisibilityType);
                            fieldsToRemove.push(...this.fieldsWithCorporateVisibilityType);
                        }
                    }
                });

                fieldsToRemove.forEach((field) => {
                    let fieldToRemove = section.fields.find(function (existingField) {
                        return existingField.apiNameOfField === field.apiNameOfField;
                    });
                    if (fieldToRemove) {
                        const index = section.fields.indexOf(fieldToRemove);
                        if (index !== -1) {
                            section.fields.splice(index, 1);
                        }
                    }
                });
                fieldsToAdd.forEach((field) => {
                    section.fields.push(field);
                });
            });
        }

        if(nameOfField == 'DOT_Government__c') {
            this.listOfDocuments.forEach((document) => {
                if(document.label == 'Document of Trust') {
                    if(valueOfField == 'Yes') {
                        document.isHide = false;
                    } else {
                        document.isHide = true;
                    }
                }
            });
        }

        let existingField = this.updatedRecordFields.find(function(field) {
            return field.apiNameOfField === nameOfField;
        });

        if (existingField) {
            existingField.value = event.detail.value;
        } else {
            this.updatedRecordFields.push({
                apiNameOfField: nameOfField,
                value: event.detail.value
            });
        }

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

    handleSaveDocument(event) {

        let documentForInsert = event.detail.documentForInsert;
        this.isSaveButtonAvailable = event.detail.isSaveButtonAvailable;
        this.documentsForInsert = [...this.documentsForInsert, documentForInsert];

    }

    handleSaveChanges() {
        this.updateRecord();
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