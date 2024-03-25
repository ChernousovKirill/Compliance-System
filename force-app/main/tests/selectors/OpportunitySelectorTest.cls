@isTest
private class OpportunitySelectorTest {
    private static final Integer NEW_RECORDS = TestConstants.NEW_RECORDS;

    @isTest
    static void getOpportunitiesByAcocunt() {
        TriggerHandler.bypass(AccountTriggerHandler.class.getName());
        TriggerHandler.bypass(OpportunityTriggerHandler.class.getName());

        List<Account> accounts = TestDataFactory.createAccounts(true, NEW_RECORDS);
        List<Opportunity> opportunities = TestDataFactory.createOpportunities(true, accounts);
        Set<Id> setIds = new Set<Id>();

        for(Account acc : accounts) {
            setIds.add(acc.Id);
        }
        Test.startTest();
        List<Opportunity> result = OpportunitySelector.getOpportunitiesByAcocunt(setIds);
        Test.stopTest();

        Assert.areEqual(result.size(), 400);
    }
}