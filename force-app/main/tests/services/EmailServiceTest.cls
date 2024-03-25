
@isTest
private class EmailServiceTest {
    private static final Integer NEW_RECORDS = TestConstants.NEW_RECORDS;

    @isTest
    static void buildEmailTemplate() {
        TriggerHandler.bypass(LeadTriggerHandler.class.getName());
        TriggerHandler.bypass(UserTriggerHandler.class.getName());

        Id profileId = [SELECT Id FROM Profile WHERE Name = :TestConstants.SYSTEM_ADMINISTRATOR LIMIT 1].Id;
        User testAdm = TestDataFactory.createUser('', profileId, TestConstants.TEST_NAME, TestConstants.TEST_NAME, false);

        System.runAs(testAdm) {
            Id folderId = UserInfo.getOrganizationId();
            EmailTemplate testTemplate = TestDataFactory.initEmailTemplate(folderId, true);

            List<Lead> testLeads = TestDataFactory.initLeads(NEW_RECORDS, null, null, false);
            insert testLeads;

            String[] toAddresses = new String[]{TestConstants.TEST_EMAIL};

            Id addressId = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = :ConstantUtility.NODA_ADDRESS LIMIT 1].Id;

            Test.startTest();
            List<Messaging.SingleEmailMessage> result = EmailService.buildEmailTemplate(testLeads, toAddresses, addressId, testTemplate.Id);
            EmailService.sendEmails(testLeads, toAddresses, addressId, testTemplate.Id);
            Test.stopTest();

            Assert.areEqual(NEW_RECORDS, result.size());
        }
    }
}