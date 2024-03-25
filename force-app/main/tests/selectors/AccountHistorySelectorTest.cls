@IsTest
private class AccountHistorySelectorTest {
    private static final Integer NEW_RECORDS = TestConstants.NEW_RECORDS;

    static List<Account> testSetup() {
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
    static void getAccounts() {
        List<Account> accounts = testSetup();
        Set<Id> accountIds = new Set<Id>();
        List<AccountHistory> accountHistories = new List<AccountHistory>();

        for (Account acc : accounts) {
            accountIds.add(acc.Id);
            AccountHistory accountHistory = new AccountHistory(
                AccountId = acc.Id,
                Field = 'Owner',
                DataType = 'EntityId'
            );
            accountHistories.add(accountHistory);
        }
        insert accountHistories;

        Test.startTest();
        List<AccountHistory> result = AccountHistorySelector.getAccountHistory(accountIds);
        Test.stopTest();

        Assert.areEqual(NEW_RECORDS, result.size());
    }
}