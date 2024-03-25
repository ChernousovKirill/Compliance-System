@IsTest
private class LeadSelectorTest {
    private static final Decimal SCORE = 6000;
    private static final Integer NEW_RECORDS = 200;
    @IsTest
    static void getLeadScoreShouldReturnZero() {
        Lead testLead = new Lead(LastName = 'Test Lead', Company = 'Test Company');
        insert testLead;

        Test.startTest();
        Decimal result = LeadSelector.getLeadScore(testLead.Id);

        Test.stopTest();

        Assert.areEqual(0, result);
    }

    @IsTest
    static void getLeadScoreShouldReturnScore() {
        Lead testLead = new Lead(LastName = 'Test Lead', Company = 'Test Company');
        testLead.General_Traffic__c = SCORE;
        testLead.Website = TestConstants.TEST_WEBSITE;

        insert testLead;

        Test.startTest();
        Decimal result = LeadSelector.getLeadScore(testLead.Id);

        Test.stopTest();

        Assert.areEqual(1, result);
    }

    @IsTest
    static void getLeadScoreShouldLeads() {
        Lead testLead = TestDataFactory.initLead(false);
        testLead.Email = TestConstants.TEST_EMAIL;
        testLead.Website = TestConstants.TEST_WEBSITE;

        insert testLead;

        Test.startTest();
        List<Lead>  result = LeadSelector.getLeadByEmailAndWebsite(TestConstants.TEST_EMAIL);

        Test.stopTest();

        Assert.areEqual(1, result.size());
    }

    @IsTest
    static void getLeadRows() {
        Lead testLead = TestDataFactory.initLead(false);
        testLead.Email = TestConstants.TEST_EMAIL;
        testLead.Website = TestConstants.TEST_WEBSITE;
        
        insert testLead;

        String searchKey = '%' + TestConstants.TEST_WEBSITE + '%';

        Test.startTest();
        List<Lead>  result = LeadSelector.getLeadRows(searchKey);
        Test.stopTest();

        Assert.areEqual(1, result.size());
        Assert.areEqual('Test Company', result.get(0).Company);
    }

    @IsTest
    static void getLeadActivityDate() {
        List<Lead> leads = TestDataFactory.initLeads(NEW_RECORDS, true);
        Set<Id> leadIds = new Set<Id>();

        for (Lead lead : leads) {
            leadIds.add(lead.Id);
        }

        Test.startTest();
        List<Lead> result = LeadSelector.getLeadActivityDate(leadIds);
        Test.stopTest();
    
        Assert.areEqual(NEW_RECORDS, result.size());
        Assert.areEqual(result.get(0).Activity_Date__c, Date.today());
    }
}