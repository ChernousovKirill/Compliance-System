trigger AccountTrigger on Account (after insert, before update, after update) {
    new AccountTriggerHandler().run();
}