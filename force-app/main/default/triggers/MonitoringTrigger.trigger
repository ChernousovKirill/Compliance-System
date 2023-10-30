trigger MonitoringTrigger on Monitoring__c (after insert) {
    
    MonitoringTriggerHandler triggerHandler = new MonitoringTriggerHandler();

    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            triggerHandler.onAfterInsert(Trigger.new);
        }
    }
}