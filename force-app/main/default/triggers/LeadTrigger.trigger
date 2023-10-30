trigger LeadTrigger on Lead (before insert, after insert, before update) {

    LeadTriggerHandler triggerHandler = new LeadTriggerHandler();

    if(Trigger.isAfter) {
        if (Trigger.isInsert) {
            triggerHandler.onAfterInsert( Trigger.new );
        }
    }
    if(Trigger.isBefore) {
        if (Trigger.isInsert) {
            triggerHandler.onBeforeInsert( Trigger.new );
        }
        if (Trigger.isUpdate) {
            triggerHandler.onBeforeUpdate( Trigger.newMap, Trigger.oldMap );
        }
    }
}