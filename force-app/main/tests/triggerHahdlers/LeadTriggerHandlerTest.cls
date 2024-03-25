@isTest
public class LeadTriggerHandlerTest {
    private static final Integer numberOfRecords = LeadTriggerHandler.batchSize;

    @isTest
    public static void beforeInsertPreferredServicesIsNotNull() {
        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());
        List<Lead> testLeads = new List<Lead>();

        testLeads.addAll(TestDataFactory.initLeads(numberOfRecords, ConstantUtility.CARDS_PROCESSING, null, false));

        Test.startTest();
        insert testLeads;
        Test.stopTest();

        List<Lead> newLeads = [SELECT Lead_with_Card_Process__c FROM Lead WHERE Id IN :testLeads];

        Assert.areEqual(numberOfRecords, newLeads.size());

        for (Lead newLead : newLeads) {
            Assert.areEqual(true, newLead.Lead_with_Card_Process__c);
        }
    }

    @isTest
    public static void beforeInsertPreferredServicesAndProductIsNotNull() {
        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());
        List<Lead> testLeads = new List<Lead>();

        testLeads.addAll(TestDataFactory.initLeads(numberOfRecords, ConstantUtility.CARDS_PROCESSING, ConstantUtility.OPEN_BANKING_PAY_INS, false));

        Test.startTest();
        insert testLeads;
        Test.stopTest();

        List<Lead> newLeads = [SELECT Lead_with_Card_Process__c FROM Lead WHERE Id IN :testLeads];

        Assert.areEqual(numberOfRecords, newLeads.size());

        for (Lead newLead : newLeads) {
            Assert.areEqual(true, newLead.Lead_with_Card_Process__c);
        }
    }

    @isTest
    public static void beforeInsertPreferredServicesAndProductIsNull() {
        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());
        List<Lead> testLeads = new List<Lead>();

        testLeads.addAll(TestDataFactory.initLeads(numberOfRecords, null, null, false));

        Test.startTest();
        insert testLeads;
        Test.stopTest();

        List<Lead> newLeads = [SELECT Lead_with_Card_Process__c FROM Lead WHERE Id IN :testLeads];

        Assert.areEqual(numberOfRecords, newLeads.size());

        for (Lead newLead : newLeads) {
            Assert.areEqual(false, newLead.Lead_with_Card_Process__c);
        }
    }

    @isTest
    public static void afterInsertWebsiteIsNull() {
        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());
        List<Lead> testLeads = TestDataFactory.initLeads(numberOfRecords, null, null, false);

        for (Lead lead : testLeads) {
            lead.Website = null;
        }

        Test.startTest();
        insert testLeads;
        Test.stopTest();

        List<Lead> updatedLeads = [SELECT Id, GEOText__c, Traffic__c, Other_GEO__c, General_Traffic__c, Industry__c FROM Lead];

        Assert.areEqual(numberOfRecords, updatedLeads.size());

        for (Lead newLead : updatedLeads) {
            Assert.isNull(newLead.Industry__c);
            Assert.isNull(newLead.GEOText__c);
            Assert.isNull(newLead.Traffic__c);
            Assert.isNull(newLead.Other_GEO__c);
            Assert.isNull(newLead.General_Traffic__c);
        }
    }

    @isTest
    public static void testOnAfterInsert() {
        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());
        List<Lead> testLeads = TestDataFactory.initLeads(numberOfRecords, null, null, false);

        List<Country__c> listOfCountries = new List<Country__c>();
        listOfCountries.add(TestDataFactory.initCountry(TestConstants.FRANCE_COUNTRY_NAME, TestConstants.FRANCE_COUNTRY_CODE, true, false));
        listOfCountries.add(TestDataFactory.initCountry(TestConstants.US_COUNTRY_NAME, TestConstants.US_COUNTRY_CODE, false, false));

        insert listOfCountries;


        Test.startTest();
        insert testLeads;
        Test.stopTest();

        List<Lead> updatedLeads = [SELECT Id, Industry__c, Product__c, PrefferedServices__c FROM Lead];
        for (Lead lead : updatedLeads) {
            Assert.isNotNull(lead.Industry__c);
            Assert.isNull(lead.PrefferedServices__c);
            Assert.isNull(lead.Product__c);
        }
    }

    @isTest
    public static void testOnBeforeUpdate() {
        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());
        List<Lead> testLeads = TestDataFactory.initLeads(numberOfRecords, null, null, false);

        for (Lead lead : testLeads) {
            lead.Website = null;
        }

        insert testLeads;

        List<Country__c> listOfCountries = new List<Country__c>();
        listOfCountries.add(TestDataFactory.initCountry(TestConstants.FRANCE_COUNTRY_NAME, TestConstants.FRANCE_COUNTRY_CODE, true, false));
        listOfCountries.add(TestDataFactory.initCountry(TestConstants.US_COUNTRY_NAME, TestConstants.US_COUNTRY_CODE, false, false));

        insert listOfCountries;

        for (Lead lead : testLeads) {
            lead.Website = 'www.example' + testLeads.indexOf(lead) + '.com';
        }

        Test.startTest();
        update testLeads;
        Test.stopTest();

        List<Lead> updatedLeads = [SELECT Id, Industry__c, GEOText__c, Traffic__c, Other_GEO__c, General_Traffic__c FROM Lead];
        for (Lead lead : updatedLeads) {
            Assert.areEqual(lead.Industry__c, TestConstants.SOME_CATEGORY_LEAD_INDUSTRY);
            Assert.isTrue(lead.GEOText__c.contains(TestConstants.FRANCE_COUNTRY_CODE));
            Assert.areEqual(lead.Traffic__c, TestConstants.FRANCE_VISITS);
            Assert.isTrue(lead.Other_GEO__c.contains(TestConstants.US_COUNTRY_CODE));
            Assert.areEqual(lead.General_Traffic__c, TestConstants.FRANCE_VISITS + TestConstants.US_VISITS);
        }
    }

    @isTest
    public static void testOnBeforeUpdateWithoutCountries() {
        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());
        List<Lead> testLeads = TestDataFactory.initLeads(numberOfRecords, null, null, false);

        for (Lead lead : testLeads) {
            lead.Website = null;
        }

        insert testLeads;

        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());

        for (Lead lead : testLeads) {
            lead.Website = 'www.example' + testLeads.indexOf(lead) + '.com';
        }

        Test.startTest();
        update testLeads;
        Test.stopTest();

        List<Lead> updatedLeads = [SELECT Id, Industry__c, GEOText__c, Traffic__c, Other_GEO__c, General_Traffic__c FROM Lead];

        for (Lead lead : updatedLeads) {
            Assert.areEqual(lead.Industry__c, TestConstants.SOME_CATEGORY_LEAD_INDUSTRY);
            Assert.areEqual(lead.Traffic__c, 0);
            Assert.areEqual(lead.General_Traffic__c, TestConstants.FRANCE_VISITS + TestConstants.US_VISITS);
        }
    }
}
