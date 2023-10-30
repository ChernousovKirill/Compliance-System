import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveLWCLog from '@salesforce/apex/LogService.saveLWCLog';
import getValuesForRecordDetailesPage from '@salesforce/apex/ApplicationFormService.getValuesForRecordDetailesPage';
import updateRecordFromDetailPage from '@salesforce/apex/ApplicationFormService.updateRecordFromDetailPage';

import cancelButtonLabel from '@salesforce/label/c.cancelButton';
import saveButtonLabel from '@salesforce/label/c.saveButtonLabel';
import labelOfErrorShowToast from '@salesforce/label/c.Something_went_wrong';
import labelOfSuccessfullySavedForm from '@salesforce/label/c.labelOfSuccessfullySavedRecord';

export default class DirectorDetailPage extends LightningElement {

    @track sections;
    @track fieldsWithIndividualVisibilityType;
    @track fieldsWithCorporateVisibilityType;
    @track listOfIndividualDocuments;
    @track listOfCorporateDocuments;
    @track showIndividualFields = false;
    @track showCorporateFields = false;
    @track isSaveButtonAvailable = false;
    @track updatedDocumentFields = [];
    @track updatedDirectorFields = [];
    @track listOfCorporateGovernmentRecords = [];
    @track listOfIndividualGovernmentRecords = [];
    @track documentsForInsert = [];

    @api recordId;
    @api objectApiName;
    @api isHideDocumentType = false;
    @api typeOfForm = 'Directors/Auth.Sign. KYC';
    @api labelOfCancelButtom = cancelButtonLabel;
    @api labelOfSaveButton = saveButtonLabel;

    connectedCallback() {
        this.getValuesForDetails();
    }

    getValuesForDetails() {
        getValuesForRecordDetailesPage({
            recordId: this.recordId,
            typeOfForm: this.typeOfForm
        }).then((result) => {
            if (result) {
                const {sections, fieldsWithIndividualVisibilityType, fieldsWithCorporateVisibilityType, listOfIndividualDocuments, listOfCorporateDocuments, listOfIndividualGovernmentRecords, listOfCorporateGovernmentRecords} = result;
                this.sections = sections;
                this.fieldsWithIndividualVisibilityType = fieldsWithIndividualVisibilityType;
                this.fieldsWithCorporateVisibilityType = fieldsWithCorporateVisibilityType;
                this.listOfIndividualDocuments = listOfIndividualDocuments;
                this.listOfCorporateDocuments = listOfCorporateDocuments;

                this.sections.forEach((section) => {
                    section.fields.forEach((field) => {
                        if (field.apiNameOfField == 'Type_Government__c') {
                            if(field.defaultValue == 'Individual') {
                                this.showIndividualFields = true;
                                section.fields.push(...this.fieldsWithIndividualVisibilityType);
                            }
                            if(field.defaultValue == 'Corporate') {
                                this.showCorporateFields = true;
                                section.fields.push(...this.fieldsWithCorporateVisibilityType);
                            }
                        }
                    });
                });

                this.sections.forEach((section) => {
                    section.fields.forEach((field) => {
                        if(field.apiNameOfField == 'DOT_Government__c') {
                            if(this.showIndividualFields) {
                                this.listOfIndividualDocuments.forEach((document) => {
                                    if(document.label == 'Document of Trust') {
                                        if(field.defaultValue == 'Yes') {
                                            document.isHide = false;
                                        } else {
                                            document.isHide = true;
                                        }
                                    }
                                });
                            } else if (this.showCorporateFields) {
                                this.listOfCorporateDocuments.forEach((document) => {
                                    if(document.label == 'Document of Trust') {
                                        if(field.defaultValue == 'Yes') {
                                            document.isHide = false;
                                        } else {
                                            document.isHide = true;
                                        }
                                    }
                                });
                            }
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

    updateRecordFromDetailsPage() {
        const directorFieldsForUpdate = {};
        this.updatedDirectorFields.forEach((field) => {
            directorFieldsForUpdate[field.apiNameOfField] = field.value;
        });
        this.directorFieldsForUpdate = directorFieldsForUpdate;

        updateRecordFromDetailPage({ recordId: this.recordId,
                                apiNameOfObject : this.objectApiName,
                                recordFieldsForUpdate: this.directorFieldsForUpdate,
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

    handleChangeDirectorFields(event) {
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
                            this.showIndividualFields = true;
                            this.showCorporateFields = false;
                        } else if (valueOfField == 'Corporate') {
                            fieldsToAdd.push(...this.fieldsWithCorporateVisibilityType);
                            fieldsToRemove.push(...this.fieldsWithIndividualVisibilityType);
                            this.showIndividualFields = false;
                            this.showCorporateFields = true;
                        } else {
                            fieldsToRemove.push(...this.fieldsWithIndividualVisibilityType);
                            fieldsToRemove.push(...this.fieldsWithCorporateVisibilityType);
                            this.showIndividualFields = false;
                            this.showCorporateFields = false;
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
            if(this.showIndividualFields) {
                this.listOfIndividualDocuments.forEach((document) => {
                    if(document.label == 'Document of Trust') {
                        if(valueOfField == 'Yes') {
                            document.isHide = false;
                        } else {
                            document.isHide = true;
                        }
                    }
                });
            } else if (this.showCorporateFields) {
                this.listOfCorporateDocuments.forEach((document) => {
                    if(document.label == 'Document of Trust') {
                        if(valueOfField == 'Yes') {
                            document.isHide = false;
                        } else {
                            document.isHide = true;
                        }
                    }
                });
            }
        }
    
        let existingField = this.updatedDirectorFields.find(function (field) {
            return field.apiNameOfField === nameOfField;
        });
    
        if (existingField) {
            existingField.value = event.detail.value;
        } else {
            this.updatedDirectorFields.push({
                apiNameOfField: nameOfField,
                value: event.detail.value
            });
        }
        console.log('this.updatedDirectorFields ' + JSON.stringify(this.updatedDirectorFields));
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
        console.log('this.updatedDocumentFields ' + JSON.stringify(this.updatedDocumentFields));
        record.fieldsToUpdate.push({ fieldApi: fieldApi, updatedValue: updatedValue });

    }

    handleSaveDocument(event) {

        let documentForInsert = event.detail.documentForInsert;
        this.isSaveButtonAvailable = event.detail.isSaveButtonAvailable;
        this.documentsForInsert = [...this.documentsForInsert, documentForInsert];

    }

    handleSaveDirectorChanges() {
        this.updateRecordFromDetailsPage();
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