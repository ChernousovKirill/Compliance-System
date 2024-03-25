@IsTest
private class OpportunityTriggerHandlerTest {
    private static final Integer NEW_RECORDS = TestConstants.NEW_RECORDS;

    @TestSetup
    static void testSetup() {
        TestDataFactory.createNodaCustomSetting();
    }

    @IsTest
    static void afterUpdateWhenStageChanged() {
        TriggerHandler.bypass(AccountTriggerHandler.class.getName());

        List<Account> accounts = TestDataFactory.createAccounts(true, NEW_RECORDS);
        List<Opportunity> opportunities = TestDataFactory.createOpportunities(true, accounts);
        List<Opportunity> updOpportunities = new List<Opportunity>();
        Boolean isError = false;

        for (Opportunity opp : opportunities) {
            if (opp.Name.contains('Noda Go') || opp.Name.contains('Noda Buffet')) {
                opp.StageName = TestConstants.TEST_STAGE;
                updOpportunities.add(opp);
            }
        }
        try {
            Test.startTest();
            update updOpportunities;
            Test.stopTest();
        } catch (Exception e) {
            System.debug(e.getMessage());
            isError = true;  
        }

        List<Account> result = [SELECT Id, Noda_Go__c, Noda_Buffet__c FROM Account WHERE Id IN :accounts AND Noda_Go__c = :TestConstants.TEST_STAGE AND Noda_Buffet__c = :TestConstants.TEST_STAGE];

        Assert.isFalse(isError);
        Assert.areEqual(NEW_RECORDS, result.size());
        Assert.areEqual(updOpportunities.size(), 400);

    }

}