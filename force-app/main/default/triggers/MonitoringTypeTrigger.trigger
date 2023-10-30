trigger MonitoringTypeTrigger on Monitoring_Type__c (after update) {

    MonitoringTypeTriggerHandler triggerHandler = new MonitoringTypeTriggerHandler();

    if(Trigger.isAfter) {
        if (Trigger.isUpdate) {
            triggerHandler.onAfterUpdate(Trigger.new);
        }
    }
}