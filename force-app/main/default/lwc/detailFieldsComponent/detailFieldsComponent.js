import { LightningElement, api, track } from 'lwc';

export default class DetailFieldsComponents extends LightningElement {
    @api field;
    @api section;
    @api objectapiname;
    @api recordid;

    @api showIndividualFields = false;
    @api showCorporateFields = false;
    @api isSaveButtonAvailable = false;
    @api isEditFormAvailable = false;

    @track updatedRecordFields = [];

    @api optionsOfStatus = [
        { value: 'Pending', label: 'Pending' },
        { value: 'Verified', label: 'Verified' },
        { value: 'Postponed', label: 'Postponed' },
        { value: 'Rejected', label: 'Rejected' },
        { value: 'Not Applicable', label: 'Not Applicable' },
        { value: 'Not Available', label: 'Not Available' }

    ];

    handleEditClick() {
        this.isEditFormAvailable = true;
    }

    handleFieldChange(event) {
        this.isSaveButtonAvailable = true;
        let nameOfField = event.target.dataset.id;
        let nameOfLookup = event.detail.apiNameOfField;
        let valueOfField;
        if(nameOfLookup == 'Director_Auth_Sign_Corporate__c' || nameOfLookup == 'Director_Auth_Sign_Government__c' || nameOfLookup == 'Corporate_KYC__c') {
            valueOfField = event.detail.idOfRecord;
            nameOfField = nameOfLookup;
        } else {
            valueOfField = event.target.value;
        }

        if (nameOfField == 'Type_Government__c') {
            if(valueOfField == 'Individual') {
                this.showIndividualFields = true;
                this.showCorporateFields = false;
            } else if(valueOfField == 'Corporate') {
                this.showIndividualFields = false;
                this.showCorporateFields = true;
            }
        }

        const selectedEvent = new CustomEvent("changefield", {
            detail:{
                isSaveButtonAvailable: this.isSaveButtonAvailable,
                showIndividualFields: this.showIndividualFields,
                showCorporateFields: this.showCorporateFields,
                apiNameOfField: nameOfField,
                value: valueOfField
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    handleChangeLicenseType(event) {
    
        let fieldApi = event.target.dataset.fieldapi;
        let recordId = event.target.dataset.id;
        let updatedValue = event.target.value;
    
        const selectedEvent = new CustomEvent("changelicensetype", {
            detail:{
                apiNameOfField: fieldApi,
                recordId: recordId,
                value: updatedValue
            }
        });
        this.dispatchEvent(selectedEvent);
    }
}