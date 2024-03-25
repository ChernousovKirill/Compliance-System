@IsTest
private class UpdateLeadsBatchTest {
    private static final Integer numberOfRecords = LeadTriggerHandler.batchSize;

    @isTest
    public static void updateLeads() {
        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());
        Set<Id> setOfIds = new Set<Id>();
        List<Country__c> listOfCountries = new List<Country__c>();

        listOfCountries.add(TestDataFactory.initCountry(TestConstants.FRANCE_COUNTRY_NAME, TestConstants.FRANCE_COUNTRY_CODE, true, false));
        listOfCountries.add(TestDataFactory.initCountry(TestConstants.US_COUNTRY_NAME, TestConstants.US_COUNTRY_CODE, false, false));

        insert listOfCountries;

        List<Lead> testLeads = TestDataFactory.initLeads(numberOfRecords, null, null, false);

        insert testLeads;

        for (Lead lead : testLeads) {
            setOfIds.add(lead.Id);
        }

        UpdateLeadsBatch updateLeadsBatch = new UpdateLeadsBatch(setOfIds);
        Test.startTest();
        Id batchProcessId = Database.executeBatch(updateLeadsBatch);
        Test.stopTest();

        List<Lead> updatedLeads = [SELECT Id, Industry__c, GEOText__c, Traffic__c, Other_GEO__c, General_Traffic__c FROM Lead];

        AsyncApexJob jobResult = [SELECT NumberOfErrors, Status FROM AsyncApexJob WHERE Id = :batchProcessId];

        Assert.areEqual(numberOfRecords, updatedLeads.size());
        Assert.areEqual(0, jobResult.NumberOfErrors);
        Assert.areEqual(ConstantUtility.COMPLETED_STATUS, jobResult.Status);

        for (Lead lead : updatedLeads) {
            Assert.areEqual(lead.Industry__c, TestConstants.SOME_CATEGORY_LEAD_INDUSTRY);
            Assert.isTrue(lead.GEOText__c.contains(TestConstants.FRANCE_COUNTRY_CODE));
            Assert.areEqual(lead.Traffic__c, TestConstants.FRANCE_VISITS);
            Assert.isTrue(lead.Other_GEO__c.contains(TestConstants.US_COUNTRY_CODE));
            Assert.areEqual(lead.General_Traffic__c, TestConstants.FRANCE_VISITS + TestConstants.US_VISITS);
        }
    }
}