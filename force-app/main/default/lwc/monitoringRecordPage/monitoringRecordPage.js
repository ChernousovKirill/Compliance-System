import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getMonitoringSections from '@salesforce/apex/MonitoringRecordPageController.getMonitoringSections';
import getMonitoringById from '@salesforce/apex/MonitoringRecordPageController.getMonitoringById';
import updateMonitoringFields from '@salesforce/apex/MonitoringRecordPageController.updateMonitoringFields';
import updateMonitoringTypeValues from '@salesforce/apex/MonitoringRecordPageController.updateMonitoringTypeValues';
import saveLWCLog from '@salesforce/apex/LogService.saveLWCLog';
import cancelButtonLabel from '@salesforce/label/c.cancelButton';
import saveButtonLabel from '@salesforce/label/c.saveButtonLabel';
import labelOfSuccessfullySavedForm from '@salesforce/label/c.labelOfSuccessfullySavedRecord';


export default class MonitoringRecordPage extends LightningElement {

    @track sections;
    @track error;
    @api recordId;

    @api labelOfCancelButton = cancelButtonLabel;
    @api labelOfSaveButton = saveButtonLabel;

    @api optionsOfLevel = [
        { value: 'Standard', label: 'Standard' },
        { value: 'Enhanced', label: 'Enhanced' }
    ];

    @api optionsOfReason = [
        { value: 'Periodic KYC review', label: 'Periodic KYC review' },
        { value: 'Merchant Notified', label: 'Merchant Notified' },
        { value: 'Event/Trigger based', label: 'Event/Trigger based' }
    ];

    @api optionsOfMonitoringStatus = [
        { value: 'Pending', label: 'Pending' },
        { value: 'Verified', label: 'Verified' },
        { value: 'Postponed', label: 'Postponed' },
        { value: 'Rejected', label: 'Rejected' },
        { value: 'Not Started', label: 'Not Started' }
    ];

    @track valueOfLastMonitoringDate;
    @track valueOfNextMonitoringDate;
    @track valueOfMonitoringCompletedDate;
    @track valueOfMonitoringStartedDate;

    @track valueOfLevel;
    @track valueOfReason;
    @track valueOfMonitoringStatus;

    @track valueOfReasonComment;
    @track valueOfNotes;

    @track showSaveCancelButtons = false;
    @track updatedMonitoringFields = [];
    @track updatedMonitoringTypeFields = [];

    connectedCallback() {
        this.getSections();
        this.getMonitoring();
    }

    getSections() {
        getMonitoringSections({           
            recordId: this.recordId
        }).then((result) => {
            if (result) {
                this.sections = result;
            }
            this.error = undefined;
        }).catch((error) => {
            this.error = error;
            saveLWCLog({ id: this.recordId, description: JSON.stringify(this.error) });
        });
    }

    getMonitoring() {
        getMonitoringById({
            recordId: this.recordId
        }).then((result) => {
            if(result) {
                this.valueOfLastMonitoringDate = result.Last_Monitoring_Date__c;
                this.valueOfNextMonitoringDate = result.Next_Monitoring_Date__c;
                this.valueOfMonitoringStartedDate = result.Monitoring_Started_Date__c;
                this.valueOfMonitoringCompletedDate = result.Monitoring_Completed__c;
                this.valueOfLevel = result.Level__c;
                this.valueOfReason = result.Reason__c;
                this.valueOfMonitoringStatus = result.Monitoring_Status__c;
                this.valueOfReasonComment = result.Reason_Comment__c;
                this.valueOfNotes = result.Notes__c;
            }
        }).catch((error) => {
            saveLWCLog({ id: this.recordId, description: JSON.stringify(error) });
        });
    }

    handleMonitoringFieldChange(event) {
        this.showSaveCancelButtons = true;

        let value = event.target.value;
        let apiNameOfField = event.target.dataset.fieldapi;

        let existingFieldIndex = this.updatedMonitoringFields.findIndex(item => item.apiNameOfUpdatedField === apiNameOfField);

        if (existingFieldIndex !== -1) {
            this.updatedMonitoringFields[existingFieldIndex].updatedValue = value;
        } else {
            this.updatedMonitoringFields.push({
                apiNameOfUpdatedField: apiNameOfField,
                updatedValue: value,
            });
        }

        console.log('updatedMonitoringFields ' + JSON.stringify(this.updatedMonitoringFields));
    }

    handleChangeMonitoringType(event) {
        this.showSaveCancelButtons = true;
    
        let fieldApi = event.target.dataset.fieldapi;
        let recordId = event.target.dataset.id;
        let updatedValue = event.target.value;
    
        let record = this.updatedMonitoringTypeFields.find(item => item.recordId === recordId);
        if (!record) {
            record = { recordId: recordId, fieldsToUpdate: [] };
            this.updatedMonitoringTypeFields.push(record);
        }
    
        record.fieldsToUpdate.push({ fieldApi: fieldApi, updatedValue: updatedValue });
    }
    

    handleSaveForm() {
        this.updateMonitoringRecord();
        this.updateMonitoringTypeRecords();
        window.location.reload();
    }

    handleCancelEditForm() {
        this.showSaveCancelButtons = false;    
    }

    updateMonitoringTypeRecords() {

        updateMonitoringTypeValues({ listOfRecordsToUpdate: this.updatedMonitoringTypeFields })
        .then(result => {
            console.log('result>>> ' + result);
        })
        .catch(error => {
            this.showToast('Error', labelOfErrorShowToast, 'Error');
            saveLWCLog({ id : this.recordid,
              description: JSON.stringify(error)})        });
    }

    updateMonitoringRecord() {

        const fieldsForUpdate = {};
        this.updatedMonitoringFields.forEach((field) => {
            fieldsForUpdate[field.apiNameOfUpdatedField] = field.updatedValue;
        });
        this.fieldsForUpdate = fieldsForUpdate;
    
        updateMonitoringFields({ recordId: this.recordId, fieldsForUpdate: this.fieldsForUpdate })
            .then(() => {
                this.showToast('', labelOfSuccessfullySavedForm, 'Success');
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

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}