public with sharing class UpdateLeadsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    private LeadUtils leadUtilsCls = new LeadUtils();
    private CountryUtils countryUtilsCls = new CountryUtils();
    private Set<Id> leadIds = new Set<Id>();

    public UpdateLeadsBatch(Set<Id> leadIds) {
        this.leadIds = leadIds;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, Website, Industry__c FROM Lead WHERE Id IN :leadIds');
    }

    public void execute(Database.BatchableContext BC, List<Lead> leads) {
        Map<Boolean, Map<String, String>> countryCodesStringsByBooleans = countryUtilsCls.getCountryCodeOfSupportedCountries();

        for (Lead lead : leads) {
            leadUtilsCls.updateIndustryOfLead(lead);
            leadUtilsCls.updateTrafficOfLead(lead, countryCodesStringsByBooleans);
        }

        update leads;
    }

    public void finish(Database.BatchableContext BC) {
    }
}