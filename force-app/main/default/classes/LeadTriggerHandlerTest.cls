@isTest
public class LeadTriggerHandlerTest {
    @isTest
    public static void testOnAfterInsert() {
        // Create test data
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 5; i++) {
            testLeads.add(new Lead(Website = 'www.example' + i + '.com', LastName = 'LastName', Company = 'Company'));
        }
        insert testLeads;

        List<Country__c> listOfCountries = new List<Country__c>();
        listOfCountries.add(new Country__c(Name = 'France', Country_Code__c = 'FR', Is_country_with_supported_banks__c = true));
        listOfCountries.add(new Country__c(Name = 'United States', Country_Code__c = 'US', Is_country_with_supported_banks__c = false));
        insert listOfCountries;

        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());

        Test.startTest();
        // Call the trigger handler method
        new LeadTriggerHandler().onAfterInsert(testLeads);
        Test.stopTest();

        // Verify that the Industry and Traffic fields have been updated correctly
        List<Lead> updatedLeads = [SELECT Id, Industry__c, GEOText__c, Traffic__c, Other_GEO__c, General_Traffic__c FROM Lead];
        System.debug('updatedLeads ' + updatedLeads);
        System.assertEquals(5, updatedLeads.size());
        for (Lead lead : updatedLeads) {
            // Add appropriate assertions based on the data and behavior of your code
            System.assertNotEquals(null, lead.Industry__c);
            System.assertNotEquals(null, lead.GEOText__c);
            System.assertNotEquals(null, lead.Traffic__c);
            System.assertNotEquals(null, lead.Other_GEO__c);
            System.assertNotEquals(null, lead.General_Traffic__c);
        }
    }

    // Add more test methods as needed to cover other functionalities of the LeadTriggerHandler class
}
