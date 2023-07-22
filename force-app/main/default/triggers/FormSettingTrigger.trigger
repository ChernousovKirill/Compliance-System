trigger FormSettingTrigger on Form_Setting__c (before insert, before update) {

    FormSettingTriggerHandler triggerHandler = new FormSettingTriggerHandler();

    if(Trigger.isBefore) {
        if (Trigger.isInsert) {
            triggerHandler.onBeforeInsert( Trigger.new );
        }
        if (Trigger.isUpdate) {
            triggerHandler.onBeforeUpdate(Trigger.oldMap,Trigger.newMap);
        }
    }
}