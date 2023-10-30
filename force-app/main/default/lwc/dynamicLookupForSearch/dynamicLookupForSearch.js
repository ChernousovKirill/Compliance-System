import { LightningElement, api } from 'lwc';
import fetchRecords from '@salesforce/apex/DynamicLookupForSearchController.fetchRecords';
/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 500;

export default class DynamicLookupForSearch extends LightningElement {
    
    @api required;
    @api field;
    listOfRecord = [];
    selectedRecordName;

    @api objectApiName;
    @api fieldApiName = "Name";
    @api searchString = "";
    @api selectedRecordId = "";
    @api recordid;
    @api parentRecordId;
    @api parentFieldApiName;

    preventClosingOfSerachPanel = false;

    get methodInput() {
        return {
            objectApiName: this.field.apiNameOfReferenceObject,
            fieldApiName: this.fieldApiName,
            searchString: this.searchString,
            selectedRecordId: this.selectedRecordId,
            parentRecordId: this.parentRecordId,
            parentFieldApiName: this.parentFieldApiName,
            idOfCustomer: this.field.idOfCustomer
        };
    }

    get showRecentRecords() {
        if (!this.listOfRecord) {
            return false;
        }
        return this.listOfRecord.length > 0;
    }

    //getting the default selected record
    connectedCallback() {
         this.selectedRecordId = this.field.defaultValue;
        if (this.selectedRecordId) {
            this.fetchSobjectRecords(true);
        }
    }

    //call the apex method
    fetchSobjectRecords(loadEvent) {
        fetchRecords({
            inputWrapper: this.methodInput,
            recordId: this.recordid
        }).then(result => {
            if (loadEvent && result) {
                this.selectedRecordName = result[0].name;
            } else if (result) {
                this.listOfRecord = JSON.parse(JSON.stringify(result));
            } else {
                this.listOfRecord = [];
            }
        }).catch(error => {
            console.log(error);
        })
    }

    get isValueSelected() {
        return this.selectedRecordId;
    }

    //handler for calling apex when user change the value in lookup
    handleChange(event) {
        this.searchString = event.target.value;
        this.fetchSobjectRecords(false);
    }

    //handler for clicking outside the selection panel
    handleBlur() {
        this.listOfRecord = [];
        this.preventClosingOfSerachPanel = false;
    }

    //handle the click inside the search panel to prevent it getting closed
    handleDivClick() {
        this.preventClosingOfSerachPanel = true;
    }

    //handler for deselection of the selected item
    handleCommit() {
        this.selectedRecordId = "";
        this.selectedRecordName = "";
    }

    //handler for selection of records from lookup result list
    handleSelect(event) {
        let selectedRecord = {
            name: event.currentTarget.dataset.namefield,
            firstField: event.currentTarget.dataset.firstfield,
            secondField: event.currentTarget.dataset.secondfield,
            idOfRecord: event.currentTarget.dataset.idofrecord,
            apiNameOfField: event.currentTarget.dataset.apinameoffield
        };
        this.selectedRecordId = selectedRecord.idOfRecord;
        this.selectedRecordName = selectedRecord.name;
        this.listOfRecord = [];
        // Creates the event
        const selectedEvent = new CustomEvent('valueselected', {
            detail:{
                idOfRecord: selectedRecord.idOfRecord,
                apiNameOfField: selectedRecord.apiNameOfField
            }
        });
        //dispatching the custom event
        this.dispatchEvent(selectedEvent);
    }
    
    //to close the search panel when clicked outside of search input
    handleInputBlur(event) {
        // Debouncing this method: Do not actually invoke the Apex call as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            if (!this.preventClosingOfSerachPanel) {
                this.listOfRecord = [];
            }
            this.preventClosingOfSerachPanel = false;
        }, DELAY);
    }

}