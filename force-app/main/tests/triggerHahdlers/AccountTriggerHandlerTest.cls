@IsTest
private class AccountTriggerHandlerTest {
    private static final Integer NEW_RECORDS = 50;

    @TestSetup
    static void testSetup() {
        TestDataFactory.createNodaCustomSetting();
    }

    @IsTest
    static void afterUpdateWhenOwnerIdIsNull() {
        TriggerHandler.bypass(OpportunityTriggerHandler.class.getName());

        List<Account> accounts = createAccounts(true);
        List<Account> updAccounts = new List<Account>();

        for (Account acc : accounts) {
            acc.OwnerId = null;

            updAccounts.add(acc);
        }

        try {
            Test.startTest();
            update updAccounts;
            Test.stopTest();

            Assert.fail();
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('owner cannot be blank'));
        }
    }

    @IsTest
    static void afterInsertAccounts() {
        TriggerHandler.bypass(OpportunityTriggerHandler.class.getName());

        Noda_Custom_Settings__c settingsOfNoda = SettingUtils.settingsOfNoda;
        Set<Id> setIds = new Set<Id>();

        List<String> listOfUpsaleOpportunities = settingsOfNoda.Upsale_Opportunity__c.split(',');
        List<Account> accounts = createAccounts(false);
        
        Test.startTest();
        insert accounts;
        Test.stopTest();
        Decimal resultSize = accounts.size() * listOfUpsaleOpportunities.size();

        List<Opportunity> result = [SELECT Id FROM Opportunity WHERE AccountId IN :accounts];
        Assert.areEqual(result.size(), resultSize);
    }

    @IsTest
    static void afterUpdateWhenOwnerChanged() {
        TriggerHandler.bypass(UserTriggerHandler.class.getName());
        TriggerHandler.bypass(OpportunityTriggerHandler.class.getName());

        List<Account> accounts = createAccountsAnotherUser(true);
        List<Account> updAccounts = new List<Account>();
        Boolean isError = false;
        Integer targetRecord = 1;

        Id currentUserId = UserInfo.getUserId();

        for (Account acc : accounts) {
            acc.OwnerId = currentUserId;

            updAccounts.add(acc);
        }

        try {
            Test.startTest();
            update updAccounts;
            Test.stopTest();
        } catch (Exception e) {
            System.debug('_row_67 ====> ______    ' +e.getMessage() +'');
            isError = true;
        }

        List<Opportunity> newOpportunities = [SELECT Id, Name, OwnerId, StageName, RecordTypeId FROM Opportunity WHERE AccountId = :accounts[targetRecord].Id];

        Noda_Custom_Settings__c settingsOfNoda = SettingUtils.settingsOfNoda;
        List<String> listOfUpsaleOpportunities = settingsOfNoda.Upsale_Opportunity__c.split(',');

        Assert.isFalse(isError);
        Assert.areEqual(accounts[targetRecord].OwnerId, newOpportunities[targetRecord].OwnerId);
        Assert.areEqual(newOpportunities.size(), listOfUpsaleOpportunities.size());
        Assert.areEqual(currentUserId, newOpportunities[targetRecord].OwnerId);
    }

    @IsTest
    static void afterUpdateWhenPayInChanged() {
        TriggerHandler.bypass(OpportunityTriggerHandler.class.getName());

        List<Account> accounts = createAccounts(true);
        Boolean isError = false;
        Integer targetRecordAcc = 1;
        Integer targetRecordOpp = 0;

        for (Account acc : accounts) {
            acc.Pay_In__c = ConstantUtility.MEETING;
        }
        Test.startTest();
        update accounts;
        Test.stopTest();
        

        List<Opportunity> newOpportunities = [SELECT Id, StageName, Service_Type__c, OwnerId FROM Opportunity WHERE AccountId = :accounts[targetRecordAcc].Id AND Service_Type__c = 'Pay In'];
        Noda_Custom_Settings__c settingsOfNoda = SettingUtils.settingsOfNoda;
        List<String> listOfUpsaleOpportunities = settingsOfNoda.Upsale_Opportunity__c.split(',');

        Assert.areEqual(accounts[targetRecordAcc].Pay_In__c, newOpportunities[targetRecordOpp].StageName);
    }

    @IsTest
    static void beforeUpdateWhenCommentChanged() {
        TriggerHandler.bypass(OpportunityTriggerHandler.class.getName());

        List<Account> accounts = createAccountsWithComment(true);
        List<Account> updAccounts = new List<Account>();
        Boolean isError = false;

        for (Account acc : accounts) {
            acc.New_Comment__c = TestConstants.TEST_NEW_COMMENT;

            updAccounts.add(acc);
        }

        try {
            Test.startTest();
            update updAccounts;
            Test.stopTest();
        } catch (Exception e) {
            System.debug(e.getMessage());
            isError = true;        
        }

        List<Account> result = [SELECT Id, Previous_comment__c FROM Account WHERE Id IN :updAccounts];

        for (Account acc : result) {
            Assert.areEqual(TestConstants.TEST_COMMENT, acc.Previous_comment__c);
        }
        Assert.isFalse(isError);
        Assert.areEqual(NEW_RECORDS, result.size());
    }

        

    private static List<Account> createAccounts(Boolean doInsert) {
        List<Account> accounts = new List<Account>();
        accounts = new List<Account>();

        for (Integer i = 0; i<NEW_RECORDS; i++) {
            Account newAcc = new TestDataFactory.AccountBuilder()
                .withName(TestConstants.TEST_NAME + i)
                .build(false);

            accounts.add(newAcc);
        }

        if (doInsert) {
            insert accounts;
        }

        return accounts;
    }
    
    private static List<Account> createAccountsWithComment(Boolean doInsert) {
        List<Account> accounts = new List<Account>();
        accounts = new List<Account>();

        for (Integer i = 0; i<NEW_RECORDS; i++) {
            Account newAcc = new TestDataFactory.AccountBuilder()
                .withName(TestConstants.TEST_NAME + i)
                .withComment()
                .build(false);

            accounts.add(newAcc);
        }

        if (doInsert) {
            insert accounts;
        }

        return accounts;
    }

    private static List<Account> createAccountsAnotherUser(Boolean doInsert) {
        Id profileId = [SELECT Id FROM Profile WHERE Name = :TestConstants.SYSTEM_ADMINISTRATOR].Id;
        User u = TestDataFactory.createUser('', profileId, 'Test', 'User', false);
        List<Account> accounts = new List<Account>();

        System.runAs(u) {
            accounts = createAccounts(doInsert);
        }

        return accounts;
    }
}