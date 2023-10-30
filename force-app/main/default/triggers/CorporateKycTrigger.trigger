trigger CorporateKycTrigger on Corporate_KYC__c (after insert) {

    CorporateKycTriggerHandler triggerHandler = new CorporateKycTriggerHandler();

    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            triggerHandler.onAfterInsert(Trigger.new);
        }
    }
}