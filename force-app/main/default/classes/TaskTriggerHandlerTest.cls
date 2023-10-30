@isTest
public class TaskTriggerHandlerTest {

    @isTest
    static void testUpdateActivityDateForLeadWhenTaskCreated() {
        // Create test Lead and Task records
        Lead testLead = new Lead(LastName = 'Test Lead', Company = 'Test Company');
        insert testLead;

        Task testTask1 = new Task(Subject = 'Test Task 1', WhoId = testLead.Id, ActivityDate = Date.today());
        Task testTask2 = new Task(Subject = 'Test Task 2', WhoId = testLead.Id, ActivityDate = Date.today() - 1);
        Task testTask3 = new Task(Subject = 'Test Task 3', WhoId = testLead.Id, ActivityDate = Date.today() + 1);

        Test.startTest();
        insert new List<Task> { testTask1, testTask2, testTask3 };
        Test.stopTest();

        // Retrieve the updated Lead record
        testLead = [SELECT Id, Activity_Date__c FROM Lead WHERE Id = :testLead.Id];
        
        // Assert that Activity_Date__c is updated to the latest Task's ActivityDate
        System.assertEquals(Date.today()+1, testLead.Activity_Date__c);
    }

    @isTest
    static void testUpdateActivityDateForLeadWhenTaskDeleted() {
        // Create test Lead and Task records
        Lead testLead = new Lead(LastName = 'Test Lead', Company = 'Test Company');
        insert testLead;

        Task testTask1 = new Task(Subject = 'Test Task 1', WhoId = testLead.Id, ActivityDate = Date.today());
        Task testTask2 = new Task(Subject = 'Test Task 2', WhoId = testLead.Id, ActivityDate = Date.today() - 1);
        Task testTask3 = new Task(Subject = 'Test Task 3', WhoId = testLead.Id, ActivityDate = Date.today() + 1);

        insert new List<Task> { testTask1, testTask2, testTask3 };

        // Delete one of the Tasks
        Test.startTest();
        delete testTask2;
        Test.stopTest();

        // Retrieve the updated Lead record
        testLead = [SELECT Id, Activity_Date__c FROM Lead WHERE Id = :testLead.Id];
        
        // Assert that Activity_Date__c is updated to the latest remaining Task's ActivityDate
        System.assertEquals(Date.today() + 1, testLead.Activity_Date__c);
    }
}
