trigger UBOTrigger on UBO__c (after insert) {
    
    UBOTriggerHandler triggerHandler = new UBOTriggerHandler();

    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            triggerHandler.onAfterInsert(Trigger.new);
        }
    }
}