import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getValuesForDetailesPage from '@salesforce/apex/CustomerDetailPageController.getValuesForDetailesPage';
import addDocumentToWrapper from '@salesforce/apex/CustomerDetailPageController.addDocumentToWrapper';
import deleteAttachment from '@salesforce/apex/FileUploadController.deleteAttachment';
import updateCustomerFromEditForm from '@salesforce/apex/CustomerDetailPageController.updateCustomerFromEditForm';
import updateAdditionalDocumentFromEditForm from '@salesforce/apex/CustomerDetailPageController.updateAdditionalDocumentFromEditForm'
import saveLWCLog from '@salesforce/apex/LogService.saveLWCLog';

import addDocumentLabel from '@salesforce/label/c.addDocumentLabel';
import cancelButtonLabel from '@salesforce/label/c.cancelButton';
import additionalDocumentLabel from '@salesforce/label/c.additionalDocumentLabel';
import valueLabel from '@salesforce/label/c.valueLabel';
import saveButtonLabel from '@salesforce/label/c.saveButtonLabel';
import documentWasDeletedLabel from '@salesforce/label/c.documentWasDeletedLabel';
import labelOfErrorShowToast from '@salesforce/label/c.Something_went_wrong';
import labelOfSuccessfullySavedForm from '@salesforce/label/c.labelOfSuccessfullySavedForm';

export default class CustomerDetailPage extends LightningElement {
    @track sections;
    @api recordId;
    @api objectApiName = 'Customer__c';
    @api listofuploadedattachments = [];
    @api optionsOfBlockedCountries;
    @api nameOfBankAccountSection = 'Bank Accounts';


    @track activeSections;
    @track isDisabled = true;
    @track isAMLRiskAssessmentCheckboxHide = true;
    @track listOfDocuments = []; 
    @track updatedFields = [];
    @track updatedAdditionalDocuments = [];
    @track insertedAdditionalDocuments = [];
    @track listOfAttachmentsBySection = {};
    @track showNewDocumentModalWindow = false;
    @track isEditFormAvailable = false;
    @track labelofModalWindow = '';
    
    @api labelOfAdditionalDocument;
    @api valueOfAdditionalDocument;

    @api labelOfAddDocumentButton = addDocumentLabel;
    @api labelOfCancelButtom = cancelButtonLabel;
    @api labelOfAdditionalDocumentField = additionalDocumentLabel;
    @api labelOfAdditionalDocumentValue = valueLabel;
    @api labelOfSaveButton = saveButtonLabel;

    @track amlRiskAssesmentFields = ['Enhanced_Periodic_KYC__c', 'SOW_SOF__c', 'Compliance_policies__c', 'Enhanced_Webshield__c', 'License__c', 'Enhnaced_Sanction_Screening__c', 'Certified_Documents__c', 'Enhanced_TM__c', 'Certified_Organizational_Chart__c', 'MLRO_Approval__c'];

     
    connectedCallback() {
        this.getValuesForDetails();
        window.addEventListener('editclick', this.handleEditEvent.bind(this));
    }

    getValuesForDetails() {
        getValuesForDetailesPage({
            recordId: this.recordId
        }).then((result) => {
            if (result) {
                const { recordOfCustomer, detailsPageSections, isAMLRiskAssessmentCheckboxHide } = result;
                this.sections = detailsPageSections;
                this.isAMLRiskAssessmentCheckboxHide = isAMLRiskAssessmentCheckboxHide;
                this.optionsOfBlockedCountries = recordOfCustomer.Country_Blocks__c.split(';');

            }
            this.error = undefined;
        }).catch((error) => {
            this.error = error;
            saveLWCLog({ id: this.recordId, description: JSON.stringify(this.error) });
        });
    }

    handleFieldChange(event) {
        let apiNameOfField = event.target.dataset.id;
        let isCheckboxField = event.target.dataset.checkbox;
        let isAdditionalCheckbox = event.target.dataset.isadditionaldocument;
        let idOfDocument = event.target.dataset.idofdocument;
        let label = event.target.dataset.label;

        let valueOfField;
        if(isCheckboxField) {
            valueOfField = event.target.checked;
            if(isAdditionalCheckbox) {
                if(idOfDocument == null || idOfDocument == '') {
                    this.insertedAdditionalDocuments.forEach((document) => {
                        if(label == document.labelOfDocument) {
                            document.value = valueOfField;
                        }
                    })
                } else {
                    this.updatedAdditionalDocuments.push({
                        recordId: idOfDocument,
                        value: valueOfField,
                    });
                    }
            }
        } else {
            valueOfField = event.target.value;
        }


        this.sections.forEach((section) => {
            section.fields.forEach((field) => {
                if (this.amlRiskAssesmentFields.includes(field.apiNameOfField)) {
                    if (apiNameOfField == 'CDD_Level__c') {
                        if(valueOfField == 'Enhanced CDD') {
                            this.isAMLRiskAssessmentCheckboxHide = false;
                        } else {
                            this.isAMLRiskAssessmentCheckboxHide = true;
                        }
                    }
                    field.isHide = this.isAMLRiskAssessmentCheckboxHide;
                }
                if (apiNameOfField == 'Business_Industry_Activity__c') {
                    if(valueOfField == 'Other') {
                        if (field.apiNameOfField == 'Other_Business_Industry_Activity__c') {
                            field.isHide = false;
                        }
                    } else {
                        if (field.apiNameOfField == 'Other_Business_Industry_Activity__c') {
                            field.isHide = true;
                        }
                    }
                }
                if(apiNameOfField == 'Country_Blocks__c') {
                    this.optionsOfBlockedCountries = valueOfField;
                }
                if(field.apiNameOfField == apiNameOfField) {
                    this.updatedFields.push({
                        apiNameOfField: field.apiNameOfField,
                        value: valueOfField,
                    });
                }
            });
        });
    }

    updateCustomerFromDetailsPage() {

        const fieldsForUpdate = {};
        this.updatedFields.forEach((field) => {
            fieldsForUpdate[field.apiNameOfField] = field.value;
        });
        this.fieldsForUpdate = fieldsForUpdate;
    
        updateCustomerFromEditForm({ recordId: this.recordId, fieldsForUpdate: this.fieldsForUpdate })
            .then(() => {
                this.showToast('', labelOfSuccessfullySavedForm, 'Success');
                window.location.reload();
            })
            .catch((error) => {
                this.showToast('Error', labelOfErrorShowToast, 'Error');
            saveLWCLog({ id : this.recordid,
              description: JSON.stringify(error)})
            });
        
            if(this.updatedAdditionalDocuments != null) {
                this.updateAdditionalDocument();
            }
    }

    updateAdditionalDocument() {
        let documentsForUpdate = {};
        let documentsForInsert = {};
        this.updatedAdditionalDocuments.forEach((document) => {
            documentsForUpdate[document.recordId] = document.value;
        });
        this.documentsForUpdate = documentsForUpdate;

        if(this.insertedAdditionalDocuments != null) {
            this.insertedAdditionalDocuments.forEach((document) => {
                documentsForInsert[document.labelOfDocument] = document.value;
            });
            this.documentsForInsert = documentsForInsert;
        }

        updateAdditionalDocumentFromEditForm({ recordId: this.recordId, updatedAdditionalDocuments: this.documentsForUpdate, insertedAdditionalDocuments: this.documentsForInsert })
            .then(() => {
            })
            .catch((error) => {
                this.showToast('Error', labelOfErrorShowToast, 'Error');
            saveLWCLog({ id : this.recordid,
            description: JSON.stringify(error)})
            });
    }

    handleOpenAddNewDocumentModal() {
        this.showNewDocumentModalWindow = true;
        this.labelOfAdditionalDocument = '';
        this.valueOfAdditionalDocument = false;
    }

    handleChangeDocumentLabel(event) {
        this.labelOfAdditionalDocument = event.detail.value;
        if(this.labelOfAdditionalDocument == null || this.labelOfAdditionalDocument == undefined || this.labelOfAdditionalDocument == 'undefined') {
            this.isDisabled = true;
        } else {
            this.isDisabled = false;
        }
    }

    handleChangeDocumentValue(event) {
        this.valueOfAdditionalDocument = event.detail.checked;
    }


    addDocument() {
        addDocumentToWrapper({
            labelOfAddtionalDocument: this.labelOfAdditionalDocument,
            valueOfAdditionDocument: this.valueOfAdditionalDocument,
        })
        .then(result => {
            this.listOfDocuments = result;
            let nameOfSection = 'AML Risk Assessment';
            this.sections.forEach((section) => {
                if(section.label == nameOfSection) {
                    this.listOfDocuments.forEach((element) => {
                        let field = {};
                        field.labelOfField = element.label;
                        field.valueOfCheckbox = element.value;
                        field.areFieldsCheckbox = true;
                        field.isAdditionalDocument = true;
                        field.isHide = false;
                        field.apiNameOfField = element.label;
                        this.amlRiskAssesmentFields.push(field.apiNameOfField);
                        section.fields.push(field);

                        this.insertedAdditionalDocuments.push({
                            labelOfDocument: element.label,
                            value: element.value
                        });
                    });
                }
            });
            this.handleCloseAddNewDocumentModal();
        });
    }

    deleteAttachment(event) {
        deleteAttachment({
            idOfContentDocument: event.detail.attachmentIdForDelete
        }).then(() => {
            let nameOfSection = event.detail.nameOfSection;
            this.sections.forEach((section) => {
                if(section.label == nameOfSection) {
                    let listOfAttachments = JSON.parse(JSON.stringify(section.listOfAttachments));
                    listOfAttachments.forEach(attachment => {
                        if (attachment.contentDocumentId == event.detail.attachmentIdForDelete) {
                            listOfAttachments.splice(listOfAttachments.indexOf(attachment), 1);
                            listOfAttachments.slice();
                        }
                    });
                    section.listOfAttachments = listOfAttachments;
                }
            });
            this.showToast('', documentWasDeletedLabel, 'Success');
        }).catch((error) => {
            console.error(error);
        });
    }

    handleSelectLookup(event) {
        
        let idOfRecord = event.detail.idOfRecord;
        let apiNameOfField = event.detail.apiNameOfField;

        this.updatedFields.push({
            apiNameOfField: apiNameOfField,
            value: idOfRecord,
        });
    }

    handleAttachmentUpload(event){
        let listOfAttachments = JSON.parse(JSON.stringify(event.detail.listOfUploadedAttachments));
        let nameOfSection = event.detail.nameOfSection;
        this.sections.forEach((section) => {
            if(section.label == nameOfSection) {
                listOfAttachments.forEach(attachment => {
                    section.listOfAttachments.push(attachment);
                });
            }
        });
        listOfAttachments = null;
    }

    handleCloseAddNewDocumentModal() {
        this.showNewDocumentModalWindow = false;
    }

    handleCancelEditForm() {
        let nameOfSection = 'AML Risk Assessment';
        this.sections.forEach((section) => {
            if(section.label == nameOfSection) {
                section.fields.forEach((field) => {
                    section.fields = section.fields.filter((field) => {
                        return !(field.isAdditionalDocument && field.idOfAdditionalDocument == null);
                    });
                });
            }
            if(section.label == this.nameOfBankAccountSection) {
                section.listOfAttachments.forEach((attachment) => {
                        attachment.isCanBeRemoved = false;
                });
            }
        });
        this.isEditFormAvailable = false;    
    }
  
    disconnectedCallback() {
        window.removeEventListener('editclick', this.handleEditEvent);
    }
    
    handleEditEvent(event) {
        this.isEditFormAvailable = event.detail.value;
        this.sections.forEach((section) => {
            if(section.label == this.nameOfBankAccountSection) {
                section.listOfAttachments.forEach((attachment) => {
                    if(attachment.statusOfAttachment == 'Approved') {
                        attachment.isCanBeRemoved = false;
                    } else {
                        attachment.isCanBeRemoved = true;
                    }
                });
            }
        });
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
