import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveLWCLog from '@salesforce/apex/LogService.saveLWCLog';
import getValuesForRecordDetailesPage from '@salesforce/apex/ApplicationFormService.getValuesForRecordDetailesPage';
import updateRecordFromDetailPage from '@salesforce/apex/ApplicationFormService.updateRecordFromDetailPage';
import cancelButtonLabel from '@salesforce/label/c.cancelButton';
import saveButtonLabel from '@salesforce/label/c.saveButtonLabel';
import labelOfErrorShowToast from '@salesforce/label/c.Something_went_wrong';
import labelOfSuccessfullySavedForm from '@salesforce/label/c.labelOfSuccessfullySavedRecord';

export default class LicenseDetailPage extends LightningElement {

    @track sections;
    @track isSaveButtonAvailable = false;
    @track isLicenseChanged = false;
    @track updatedLicenseFields = [];
    @track updatedLicenseTypeFields = [];
    @track documentsForInsert = [];
    @track updatedDocumentFields = [];
    @track listOfDocuments;

    @api recordId;
    @api objectApiName;
    @api typeOfForm = 'License';
    @api labelOfCancelButtom = cancelButtonLabel;
    @api labelOfSaveButton = saveButtonLabel;

    connectedCallback() {
        this.getValuesForDetails();
        console.log('objectApiName ' + this.objectApiName);
    }

    getValuesForDetails() {
        getValuesForRecordDetailesPage({
            recordId: this.recordId,
            typeOfForm: this.typeOfForm
        }).then((result) => {
            if (result) {
                const {sections, listOfDocuments} = result;
                this.sections = sections;
                this.listOfDocuments = listOfDocuments;
            }
            this.error = undefined;
        }).catch((error) => {
            this.error = error;
            saveLWCLog({ id: this.recordId, description: JSON.stringify(this.error) });
        });
    }

    handleChangeLicenseFields(event) {

        this.isSaveButtonAvailable = event.detail.isSaveButtonAvailable;
        let nameOfField = event.detail.apiNameOfField;
        let value = event.detail.value;
        
        let existingField = this.updatedLicenseFields.find(function(field) {
            return field.apiNameOfField === nameOfField;
        });

        if (existingField) {
            existingField.value = value;
        } else {
            this.updatedLicenseFields.push({
                apiNameOfField: nameOfField,
                value: value
            });
        }
    }

    handleChangeLicenseType(event) {
        this.isSaveButtonAvailable = true;
    
        let fieldApi = event.detail.apiNameOfField;
        let recordId = event.detail.recordId;
        let updatedValue = event.detail.value;
    
        let record = this.updatedLicenseTypeFields.find(item => item.idOfLicenseType === recordId);
        if (!record) {
            record = { idOfLicenseType: recordId, fieldsToUpdate: [] };
            this.updatedLicenseTypeFields.push(record);
        }
    
        record.fieldsToUpdate.push({ fieldApi: fieldApi, updatedValue: updatedValue });
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
    
        record.fieldsToUpdate.push({ fieldApi: fieldApi, updatedValue: updatedValue })
    }

    updateLicenseFromDetailsPage() {

        const licenseFieldsForUpdate = {};
        this.updatedLicenseFields.forEach((field) => {
            licenseFieldsForUpdate[field.apiNameOfField] = field.value;
        });
        this.licenseFieldsForUpdate = licenseFieldsForUpdate;
    
        updateRecordFromDetailPage({ recordId: this.recordId,
                                    apiNameOfObject : this.objectApiName,
                                    recordFieldsForUpdate: this.licenseFieldsForUpdate,
                                    listOfUpdatedDocumentFields: this.updatedDocumentFields,
                                    listOfDocumentsForInsert: this.documentsForInsert,
                                    listOfLicenseTypeRecordsToUpdate: this.updatedLicenseTypeFields })
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

    handleSaveDocument(event) {

        let documentForInsert = event.detail.documentForInsert;
        this.isSaveButtonAvailable = event.detail.isSaveButtonAvailable;
        this.documentsForInsert = [...this.documentsForInsert, documentForInsert];

    }

    handleSaveLicenseChanges() {
        this.updateLicenseFromDetailsPage();
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