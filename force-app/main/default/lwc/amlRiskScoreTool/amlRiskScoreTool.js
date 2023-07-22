import { LightningElement, wire, track, api } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAmlRiskScoreSection from '@salesforce/apex/AmlRiskScoreToolController.getAmlRiskScoreSection';
import getAMLOfficersForAmlTool from '@salesforce/apex/AmlRiskScoreToolController.getAMLOfficersForAmlTool';
import getValuesForAmlRiskTool from '@salesforce/apex/AmlRiskScoreToolController.getValuesForAmlRiskTool';
import updateCustomerFromAmlTool from '@salesforce/apex/AmlRiskScoreToolController.updateCustomerFromAmlTool'
import saveLWCLog from '@salesforce/apex/LogService.saveLWCLog';

import labelOfCustomerName from '@salesforce/label/c.labelOfCustomerName';
import labelOfDate from '@salesforce/label/c.labelOfDate';
import labelOfAmlOfficer from '@salesforce/label/c.labelOfAmlOfficer';
import labelOfFinalRiskLevel from '@salesforce/label/c.labelOfFinalRiskLevel';
import labelOfAmlRiskScore from '@salesforce/label/c.labelOfAmlRiskScore';
import labelOfErrorShowToast from '@salesforce/label/c.Something_went_wrong';
import labelOfSuccessfullySavedForm from '@salesforce/label/c.labelOfSuccessfullySavedForm';
import cancelButton from '@salesforce/label/c.cancelButton';

export default class AmlRiskScoreTool extends LightningElement {

    sections = [];

    @api nameofcustomer;
    @api recordid;

    @api cancelButtonLabel = cancelButton;
    @api customerNameLabel = labelOfCustomerName
    @api dateLabel = labelOfDate;
    @api amlOfficerLabel = labelOfAmlOfficer;
    @api finalRiskLevelLabel = labelOfFinalRiskLevel;
    @api amlRiskScoreLabel = labelOfAmlRiskScore;

    @track totalScore = 0;
    @track levelByScorecard;

    @track fieldValues = {};
    @track fieldsForUpdate = {};

    @track labelOfReasonPicklist;

    @track apiNameOfCustomer = 'Customer__c';
    @track apiNameOfReason = 'Reason_of_AML__c';
    @track apiNameOfDate = 'Date_of_AML__c';
    @track apiNameOfOfficer = 'AML_Officer__c';
    @track apiNameOfReasonPicklist = 'Customer__c.Reason_of_AML__c';
    @track idOfRecordType;
    @track optionsOfReasonAmlRiskForm = [];
    @track amlOfficerOptions = [];

    @track valueOfReason;
    @track finalRiskLevel;
    @track dateOfAmlTool;
    @track amlOfficer;

    @wire(getAmlRiskScoreSection, {})
    wiredAmlRiskScoreSections({ error, data }) {
        if (data) {
            this.getAMLOfficerOptions();

            getValuesForAmlRiskTool({ recordId: this.recordid })
                .then((result) => {
                    const { customer, totalScore, amlRiskScoreSections } = result;
                    this.sections = amlRiskScoreSections;
                    const fieldApiNames = this.sections.flatMap((section) =>
                        section.fields.map((field) => field.apiNameOfField)
                    );
                    if (customer) {
                        this.sections.forEach((section) => {
                            section.fields.forEach((field) => {
                                const fieldApiName = field.apiNameOfField;
                                field.defaultValue = customer[fieldApiName] || "BLANK";
                            });
                        });
                    }
                    this.valueOfReason = customer[this.apiNameOfReason] != null ? customer[this.apiNameOfReason] : 'Scorecard (default)';
                    this.dateOfAmlTool = customer[this.apiNameOfDate] != null ? customer[this.apiNameOfDate] : '';
                    this.amlOfficer = customer[this.apiNameOfOfficer] != null ? customer[this.apiNameOfOfficer] : '';
                    this.sections = amlRiskScoreSections.map((section) => {
                        const fieldsWithDefaults = section.fields.map((field) => {
                            const selectedOption = field.options.find((option) => option.value === field.defaultValue);
                            if (selectedOption) {
                                field.score = selectedOption.score;
                            }
                            return field;
                        });
                        return {
                            ...section,
                            fields: fieldsWithDefaults,
                        };
                    });

                    this.totalScore = totalScore;
                    this.updateScorecardRiskLevel();
                })
                .catch((error) => {
                    saveLWCLog({ id: this.recordid, description: JSON.stringify(error) });
                });
        } else if (error) {
            saveLWCLog({ id : this.recordid, description: JSON.stringify(error) });
        }
    }

    @wire(getObjectInfo, { objectApiName: '$apiNameOfCustomer' })
    getObjectData({ error, data }) {
        if (data) {
            if (this.idOfRecordType == null) {
                this.idOfRecordType = data.defaultRecordTypeId;
                this.labelOfReasonPicklist = data.fields[this.apiNameOfReason].label;
            }
        } else if (error) {
            saveLWCLog({ id : this.recordid, description: JSON.stringify(error) });
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$idOfRecordType', fieldApiName: '$apiNameOfReasonPicklist' })
    getPicklistValues({ error, data }) {
        if (data) {
            this.optionsOfReasonAmlRiskForm = data.values.map((reasonValue) => {
                return {
                    label: reasonValue.label,
                    value: reasonValue.value,
                };
            });
        } else if (error) {
            saveLWCLog({ id : this.recordid, description: JSON.stringify(error) });
        }
    }

    getAMLOfficerOptions() {
        getAMLOfficersForAmlTool({ recordId: this.recordid })
            .then((result) => {
                let amlOfficerOptions = [];
                if (result) {
                    result.forEach((data) => {
                        amlOfficerOptions.push({
                            label: data.Name,
                            value: data.Id,
                        });
                    });
                }
                this.amlOfficerOptions = amlOfficerOptions;
            })
            .catch((error) => {
                saveLWCLog({ id : this.recordid, description: JSON.stringify(error) });
            });
    }

    handleComboboxChange(event) {
        const apiNameOfField = event.target.dataset.id;
        const selectedValue = event.detail.value;

        const newSections = [...this.sections];
        let sumOfScores = 0;

        newSections.forEach((section) => {
            section.fields.forEach((field) => {
                if (field.apiNameOfField === apiNameOfField) {
                    const selectedOption = field.options.find((option) => option.value === selectedValue);
        
                    if (selectedOption) {
                        field.score = selectedOption.score;
                        field.defaultValue = selectedOption.value
                    }
                }
                sumOfScores += field.score;
            });
        });

        this.sections = newSections;
        this.totalScore = sumOfScores;
        this.updateScorecardRiskLevel();
    }

    updateScorecardRiskLevel() {
        if (1 <= this.totalScore && this.totalScore <= 45) {
            this.levelByScorecard = 'Low Risk';
        } else if (46 <= this.totalScore && this.totalScore <= 54) {
            this.levelByScorecard = 'Medium Risk';
        } else if (this.totalScore >= 55) {
            this.levelByScorecard = 'High Risk';
        }
        this.updateFinalRiskLevel();
    }

    handleOnchangeReason(event) {
        this.valueOfReason = event.detail.value;
        this.updateFinalRiskLevel();
    }

    handleDateOfAmlFrom(event) {
        this.dateOfAmlTool = event.detail.value;
    }

    handleAmlOfficer(event) {
        this.amlOfficer = event.detail.value;
    }

    updateFinalRiskLevel() {
        if (this.valueOfReason !== 'Scorecard (default)') {
            this.finalRiskLevel = 'High Risk';
        } else {
            this.finalRiskLevel = this.levelByScorecard;
        }
    }

    updateCustomerAndClose() {
        const updatedFields = [];
        
        this.sections.forEach((section) => {
            section.fields.forEach((field) => {
                updatedFields.push({
                    apiNameOfField: field.apiNameOfField,
                    value: field.defaultValue,
                });
            });
        });

        updatedFields.push({apiNameOfField: 'Reason_of_AML__c', value: this.valueOfReason});
        updatedFields.push({apiNameOfField: 'AML_Risk_Level__c', value: this.finalRiskLevel});
        updatedFields.push({apiNameOfField: 'Score__c', value: this.totalScore});
        updatedFields.push({apiNameOfField: 'Date_of_AML__c', value: this.dateOfAmlTool});
        updatedFields.push({apiNameOfField: 'AML_Officer__c', value: this.amlOfficer});
    
        const fieldsForUpdate = {};
        updatedFields.forEach((field) => {
            fieldsForUpdate[field.apiNameOfField] = field.value;
        });
        this.fieldsForUpdate = fieldsForUpdate;
    
        updateCustomerFromAmlTool({ recordId: this.recordid, fieldsForUpdate: this.fieldsForUpdate })
            .then(() => {
                this.handleClose();
                this.showToast('', labelOfSuccessfullySavedForm, 'Success');
            })
            .catch((error) => {
                this.showToast('Error', labelOfErrorShowToast, 'Error');
            saveLWCLog({ id : this.recordid,
              description: JSON.stringify(error)})
            });
    }
    

    handleClose() {
        const showModalWindow = false;
        this.dispatchEvent(new CustomEvent('close', {
            detail: showModalWindow
        }));
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
