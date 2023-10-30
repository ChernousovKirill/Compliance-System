trigger CustomerTrigger on Customer__c (before update, after insert) {
    
    CustomerTriggerHandler triggerHandler = new CustomerTriggerHandler();

    if(Trigger.isBefore) {
        if (Trigger.isUpdate) {
            triggerHandler.onBeforeUpdate(Trigger.oldMap,Trigger.newMap);
        }
    }
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            triggerHandler.onAfterInsert(Trigger.new);
        }
    }
}