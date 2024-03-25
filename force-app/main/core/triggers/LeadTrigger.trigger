trigger LeadTrigger on Lead (before insert, after insert, before update) {
    new LeadTriggerHandler().run();
}