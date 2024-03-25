trigger TaskTrigger on Task (after insert, after delete, after update) {
    new TaskTriggerHandler().run();
}