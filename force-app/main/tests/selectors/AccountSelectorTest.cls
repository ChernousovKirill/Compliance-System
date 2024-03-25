@IsTest
private class AccountSelectorTest {
    private static final Integer NEW_RECORDS = 200;

    static List<Account> testSetup() {
        List<Account> accounts = new List<Account>();

        for (Integer i = 0; i<NEW_RECORDS; i++) {
            Account newAcc = new TestDataFactory.AccountBuilder()
                .withName(TestConstants.TEST_NAME + i)
                .withActivityDate()
                .build(false);

            accounts.add(newAcc);
        }

        insert accounts;
        return accounts;
    }

    @IsTest
    static void getAccounts() {
        List<Account> accounts = testSetup();
        Set<Id> accountIds = new Set<Id>();

        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

        Test.startTest();
        List<Account> result = AccountSelector.getAccounts(accountIds);
        Test.stopTest();

        Assert.areEqual(NEW_RECORDS, result.size());
    }

    @IsTest
    static void getAccountRows() {
        List<Account> accounts = testSetup();
        String searchKey = '%' + TestConstants.TEST_NAME + '%';

        Test.startTest();
        List<Account> result = AccountSelector.getAccountRows(searchKey);
        Test.stopTest();

        Assert.areEqual(NEW_RECORDS, result.size());
    }

    @IsTest
    static void getAccountActivityDate() {
        List<Account> accounts = testSetup();
        Set<Id> accountIds = new Set<Id>();

        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

        Test.startTest();
        List<Account> result = AccountSelector.getAccountActivityDate(accountIds);
        Test.stopTest();
    
        Assert.areEqual(NEW_RECORDS, result.size());
        Assert.areEqual(result.get(0).Activity_Date__c, Date.today());
    }
}