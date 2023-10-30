trigger LicenseTypeTrigger on License_Type__c(after update) {

    LicenseTypeTriggerHandler triggerHandler = new LicenseTypeTriggerHandler();

    if(Trigger.isAfter) {
        if (Trigger.isUpdate) {
            triggerHandler.onAfterUpdate(Trigger.new);
        }
    }
}