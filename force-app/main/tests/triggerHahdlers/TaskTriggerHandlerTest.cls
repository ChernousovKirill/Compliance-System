@isTest
public class TaskTriggerHandlerTest {
    @isTest
    static void testUpdateActivityDateForLeadWhenTaskCreated() {
        Lead testLead = TestDataFactory.initLead(true);

        List<Task> tasks = TestDataFactory.initTasks(3, testLead.Id, false);
        tasks[1].ActivityDate = Date.today().addDays(-1);
        tasks[2].ActivityDate = Date.today().addDays(1);

        Test.startTest();
        insert tasks;
        Test.stopTest();

        testLead = [SELECT Id, Activity_Date__c FROM Lead WHERE Id = :testLead.Id];

        Assert.areEqual(Date.today() + 1, testLead.Activity_Date__c);
    }

    @isTest
    static void testUpdateActivityDateForLeadWhenTaskDeleted() {
        Lead testLead = TestDataFactory.initLead(true);

        List<Task> tasks = TestDataFactory.initTasks(3, testLead.Id, false);
        tasks[1].ActivityDate = Date.today().addDays(-1);
        tasks[2].ActivityDate = Date.today().addDays(1);

        insert tasks;

        Test.startTest();
        delete tasks[1];
        Test.stopTest();

        testLead = [SELECT Id, Activity_Date__c FROM Lead WHERE Id = :testLead.Id];

        Assert.areEqual(Date.today() + 1, testLead.Activity_Date__c);
    }

    @isTest
    static void testUpdateActivityDateForLeadWhenTaskUpdated() {
        Lead testLead = TestDataFactory.initLead(true);
        Task tasks = TestDataFactory.initTask(1, testLead.Id, true);

        Test.startTest();
        tasks.ActivityDate = Date.today().addDays(1);
        update tasks;
        Test.stopTest();

        testLead = [SELECT Id, Activity_Date__c FROM Lead WHERE Id = :testLead.Id];

        Assert.areEqual(Date.today().addDays(1), testLead.Activity_Date__c);
    }
}
