import { LightningElement, track } from 'lwc';
import getAccountData from '@salesforce/apex/HomePageSearchController.getAccountData';
import getLeadData from '@salesforce/apex/HomePageSearchController.getLeadData';

import {parseErrorMessage, formatError, errorLogger} from 'c/utils';

const ACCOUNT_COLUMNS = [
    {label:'Name', fieldName:'linkToAcc', type:'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }, sortable: true},
    {label:'Industry', fieldName:'Industry', type:'text', sortable: true},
    {label:'Owner', fieldName:'OwnerFullName__c', type:'text', sortable: true},
    {label:'Website', fieldName:'Website', type:'url', sortable: true},
    {label:'Status', fieldName:'Status__c', type:'text', sortable: true},
    {label:'Activity Date', fieldName:'Activity_Date__c', type:'date', sortable: true}
];

const LEAD_COLUMS = [
    {label:'Name', fieldName:'linkToLead', type:'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }, sortable: true},
    {label:'Industry', fieldName:'Industry', type:'text', sortable: true},
    {label:'Company', fieldName:'Company', type:'text', sortable: true},
    {label:'Owner', fieldName:'OwnerFullName__c', type:'text', sortable: true},
    {label:'Website', fieldName:'Website', type:'url', sortable: true},
    {label:'Status', fieldName:'Status', type:'text', sortable: true},
    {label:'LeadSource', fieldName:'LeadSource', type:'text', sortable: true},
    {label:'Activity Date', fieldName:'Activity_Date__c', type:'date', sortable: true}
];

export default class HomePageSearch extends LightningElement {
    searchKey;
    accountColumns = ACCOUNT_COLUMNS;
    leadColumns = LEAD_COLUMS;

    @track accounts;
    @track leads;
    @track isRecordsVisible = false;
    @track isLeadVisible = false;
    @track isAccountVisible = false;

    handleSearchKey(event){
        this.searchKey = event.target.value;
    }

    searchRecordHandler() {
        this.searchAccountHandler();
        this.searchLeadHandler();
    }

    searchAccountHandler() {
        getAccountData({searchKey: this.searchKey})
        .then(result => {
            let accounts = result;
            accounts.forEach(acc => {
                acc.linkToAcc = '/' + acc.Id;
            });
            this.accounts = accounts;
            if(this.accounts && this.accounts.length > 0) {
                this.isAccountVisible = true;
            } else {
                this.isAccountVisible = false;
            }
            this.isRecordsVisible = true;
        })
        .catch( error=>{
            errorLogger({
                logMessage: JSON.stringify(error),
                recordId: this.recordid,
            }).catch((err) => {
                console.error(err)
            });
        });
    }

    searchLeadHandler() {
        getLeadData({searchKey: this.searchKey})
        .then(result => {
            let leads = result;
            leads.forEach(lead => {
                lead.linkToLead = '/' + lead.Id;
            });
            this.leads = leads;
            if(this.leads && this.leads.length > 0) {
                this.isLeadVisible = true;
            } else {
                this.isLeadVisible = false;
            }
        })
        .catch( error=>{
            errorLogger({
                logMessage: JSON.stringify(error),
                recordId: this.recordid,
            }).catch((err) => {
                console.error(err)
            });
        });
    }
}