
@isTest
private class LeadServiceTest {
    private static final Integer NEW_RECORDS = 200;
    private static final Integer ONE_RECORD = 1;

    @isTest
    static void asignDigitalLeadManagers() {
        TriggerHandler.bypass(LeadTriggerHandler.class.getName());
        TriggerHandler.bypass(UserTriggerHandler.class.getName());

        Id admProfileId = [SELECT Id FROM Profile WHERE Name = :TestConstants.SYSTEM_ADMINISTRATOR LIMIT 1].Id;
        User testAdm = TestDataFactory.createUser('', admProfileId, TestConstants.TEST_NAME, TestConstants.TEST_NAME, false);

        System.runAs(testAdm) {
            List<Lead> testLeads = TestDataFactory.initLeads(NEW_RECORDS, null, null, false);
            insert testLeads;

            Id userId = [
                SELECT Id, Name, Email
                FROM User 
                WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = :ConstantUtility.DIGITAL_LEAD_GROUP)
            ].Id;

            Test.startTest();
            LeadService.asignDigitalLeadManagers(testLeads);
            update testLeads;
            Test.stopTest();

            Assert.areEqual(userId, testLeads.get(0).OwnerId);
        }
    }

    @isTest
    static void createCallTask() {
        TriggerHandler.bypass(LeadTriggerHandler.class.getName());
        Set<Id> setIds = new Set<Id>();

        List<Lead> testLeads = TestDataFactory.initLeads(NEW_RECORDS, null, null, false);
        insert testLeads;

        Test.startTest();
        LeadService.createCallTask(testLeads);
        Test.stopTest();

        for(Lead lead : testLeads) {
            setIds.add(lead.Id);
        }

        List<Task> result = [SELECT Id FROM Task WHERE WhoId IN :setIds];
        System.assertEquals(NEW_RECORDS, result.size());
    }

    @isTest
    static void sendEmailForManagers() {
        List<Lead> testLeads = TestDataFactory.initLeads(ONE_RECORD, null, null, false);
        insert testLeads;

        Test.startTest();
            LeadService.sendEmailForManagers(testLeads);
        Test.stopTest();

    }
}