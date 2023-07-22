trigger CustomerTrigger on Customer__c (before update) {
    
    CustomerTriggerHandler triggerHandler = new CustomerTriggerHandler();

    if(Trigger.isBefore) {
        if (Trigger.isUpdate) {
            triggerHandler.onBeforeUpdate(Trigger.oldMap,Trigger.newMap);
        }
    }
}