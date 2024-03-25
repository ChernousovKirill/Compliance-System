@isTest
private class HomePageSearchControllerTest {
    private static final Integer NEW_RECORDS = 200;

    static List<Account> createAccounts() {
        List<Account> accounts = new List<Account>();

        for (Integer i = 0; i<NEW_RECORDS; i++) {
            Account newAcc = new TestDataFactory.AccountBuilder()
                .withName(TestConstants.TEST_NAME + i)
                .build(false);

            accounts.add(newAcc);
        }

        insert accounts;
        return accounts;
    }

    @IsTest
    static void getAccountData() {
        List<Account> accounts = createAccounts();
        String searchKey = '%' + TestConstants.TEST_NAME + '%';

        Test.startTest();
        List<Account> result = HomePageSearchController.getAccountData(searchKey);
        Test.stopTest();

        Assert.areEqual(NEW_RECORDS, result.size());
    }

    @IsTest
    static void getLeadData() {
        TriggerHandler.bypass(LeadTriggerHandler.class.getName());

        List<Lead> leads = TestDataFactory.initLeads(NEW_RECORDS, false);
        for(Lead lead : leads) {
            lead.Email = TestConstants.TEST_EMAIL;
            lead.Website = TestConstants.TEST_WEBSITE;
        }
        insert leads;


        String searchKey = '%' + TestConstants.TEST_WEBSITE + '%';

        Test.startTest();
        List<Lead>  result = HomePageSearchController.getLeadData(searchKey);
        Test.stopTest();

        Assert.areEqual(NEW_RECORDS, result.size());
        Assert.areEqual('Test Company', result.get(0).Company);
    }

    @IsTest
    static void getAccountDataWithNullSearchKey() {
        Test.startTest();
        List<Account> result = HomePageSearchController.getAccountData(null);
        Test.stopTest();

        System.assertEquals(null, result);
    }

    @IsTest
    static void getLeadDataWithNullSearchKey() {
        Test.startTest();
        List<Lead> result = HomePageSearchController.getLeadData(null);
        Test.stopTest();

        System.assertEquals(null, result);
    }

    @IsTest
    static void getAccountDataError() {

        try {
            Test.startTest();
            HomePageSearchController.getAccountData(TestConstants.TEST_SEARCH_KEY);
            Test.stopTest();
            Assert.fail('Expected exception was not thrown');
        } catch (System.AuraHandledException e) {
            System.assert(e.getMessage().contains('Script-thrown exception'),
                          'Expected exception message not found');
        }
    }

    @IsTest
    static void getLeadDataError() {

        try {
            Test.startTest();
            HomePageSearchController.getLeadData(TestConstants.TEST_SEARCH_KEY);
            Test.stopTest();
            Assert.fail('Expected exception was not thrown');
        } catch (System.AuraHandledException e) {
            System.assert(e.getMessage().contains('Script-thrown exception'),
                          'Expected exception message not found');
        }
    }
}