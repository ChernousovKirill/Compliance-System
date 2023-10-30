trigger DirectorTrigger on Director__c (after insert) {

    DirectorTriggerHandler triggerHandler = new DirectorTriggerHandler();

    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            triggerHandler.onAfterInsert(Trigger.new);
        }
    }
}