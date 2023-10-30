public class LeadTriggerHandler {
    
    public void onAfterInsert( List<Lead> listOfLeads){

        Set<Id> setOfIds = new Set<Id>();
        
        for(Lead lead : listOfLeads) {
            if(lead.Website != null) {
                setOfIds.add(lead.Id);
            }
        }
        if(!setOfIds.isEmpty()) {
            updateIndustryOfLead(setOfIds);
            updateTrafficOfLead(setOfIds);
        }
    }


    public void onBeforeInsert( List<Lead> listOfLeads){

        for(Lead lead : listOfLeads) {

            if((lead.PrefferedServices__c != null && lead.PrefferedServices__c.contains('Cards Processing')) || (lead.Product__c != null && lead.Product__c.contains('Cards Processing'))) {
                lead.Lead_with_Card_Process__c = true;
            }
        }
       
    }
    

    public void onBeforeUpdate(Map<Id,Lead> oldMap, Map<Id,Lead> newMap){
        
        Set<Id> setOfIds = new Set<Id>();
        for(Lead lead : newMap.values()) {
            if(lead.Website != oldMap.get(lead.Id).Website && (lead.Website != null ||  lead.Website != '')) {
                setOfIds.add(lead.Id);
            }
        }
        if(!setOfIds.isEmpty()) {
            updateIndustryOfLead(setOfIds);
            updateTrafficOfLead(setOfIds);
        }
    }

    @future(callout=true)
    public static void updateIndustryOfLead(Set<Id> leadIds) {
        
        List<Lead> leadsToUpdate = new List<Lead>();

        for (Lead lead : [SELECT Id, Website, Industry__c FROM Lead WHERE Id IN :leadIds]) {
                String industry = SimilarWebRestApiService.getIndustryOfWebsite(getCorrectLinkOfWebsite(lead.Website));
                lead.Industry__c = industry;
                leadsToUpdate.add(lead);
        }
        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
    }

    @future(callout=true)
    public static void updateTrafficOfLead(Set<Id> leadIds) {
        
        List<Lead> leadsToUpdate = new List<Lead>();
        Map<String, String> mapOfSupportedCountryCodeByName = getCountryCodeOfSupportedCountries(true);
        Map<String, String> mapOfUnsupportedCountryCodeByName = getCountryCodeOfSupportedCountries(false);

        for (Lead lead : [SELECT Id, Website, Industry__c FROM Lead WHERE Id IN :leadIds]) {
                Map<String, String> mapOfTrafficByCountryCode = SimilarWebRestApiService.getCountryAndTrafficFromWebsite(getCorrectLinkOfWebsite(lead.Website), mapOfSupportedCountryCodeByName, mapOfUnsupportedCountryCodeByName);
                    lead.GEOText__c = mapOfTrafficByCountryCode.get('valueOfSupportedGeoField');
                    lead.Traffic__c = mapOfTrafficByCountryCode.get('valueOfSupportedTraffic') != null ? Decimal.valueOf(mapOfTrafficByCountryCode.get('valueOfSupportedTraffic')) : 0;
                    lead.Other_GEO__c = mapOfTrafficByCountryCode.get('valueOfUnsupportedGeoField');
                    lead.General_Traffic__c =  mapOfTrafficByCountryCode.get('valueOfGeneralTraffic') != null ? Decimal.valueOf(mapOfTrafficByCountryCode.get('valueOfGeneralTraffic')) : 0;

                leadsToUpdate.add(lead);
        }
        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
    }

    private static Map<String, String> getCountryCodeOfSupportedCountries(Boolean isCountryWithSupportedBankd) {
        
        Map<String, String> mapOfCountryCodeByName = new Map<String, String> ();
        List<Country__c> listOfCountries = [SELECT Name, Country_Code__c FROM Country__c WHERE Is_country_with_supported_banks__c = :isCountryWithSupportedBankd];

        if(!listOfCountries.isEmpty()) {
            for(Country__c country : listOfCountries) {
                mapOfCountryCodeByName.put(country.Name, country.Country_Code__c);
            }
        }

        return mapOfCountryCodeByName;
    }

    private static String getCorrectLinkOfWebsite(String urlOfWebsite) {

        String urlOfWebsiteToLowerCase = urlOfWebsite.toLowerCase();
        
        Integer indexOfThreeW = urlOfWebsiteToLowerCase.indexOf('www.');
        String urlForSimilarweb = '';

        if (indexOfThreeW != -1) {
            urlForSimilarweb = urlOfWebsiteToLowerCase.substring(indexOfThreeW + 4);
        } else {
            urlForSimilarweb = urlOfWebsiteToLowerCase;
        }

        if (urlForSimilarweb.endsWith('/')) {
            urlForSimilarweb = urlForSimilarweb.substring(0, urlForSimilarweb.length() - 1);
        }
        return urlForSimilarweb;
    }
}