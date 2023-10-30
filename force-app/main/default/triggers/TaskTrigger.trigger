trigger TaskTrigger on Task (after insert, after delete, after update) {
    
    TaskTriggerHandler triggerHandler = new TaskTriggerHandler();

    if(Trigger.isAfter) {
        if (Trigger.isInsert) {
            triggerHandler.onAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            triggerHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
        }
        if (Trigger.isDelete) {
            triggerHandler.onAfterDelete(Trigger.old);
        }
    }
}