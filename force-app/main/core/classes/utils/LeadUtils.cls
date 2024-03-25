public with sharing class LeadUtils {
    public Utils utilsCls {
        get {
            if (utilsCls == null) {
                utilsCls = new Utils();
            }

            return utilsCls;
        }
        set;
    }

    public Lead updateIndustryOfLead(Lead lead) {
        String industry = SimilarWebRestApiService.getIndustryOfWebsite(utilsCls.getCorrectLinkOfWebsite(lead.Website));

        lead.Industry__c = industry;

        return lead;
    }

    public Lead updateTrafficOfLead(Lead lead, Map<Boolean, Map<String, String>> countryCodesStringsByBooleans) {
        Map<String, String> supportedCountryCodeByName = countryCodesStringsByBooleans.get(true);
        Map<String, String> unsupportedCountryCodeByName = countryCodesStringsByBooleans.get(false);

        String correctedUrl = utilsCls.getCorrectLinkOfWebsite(lead.Website);

        Map<String, String> mapOfTrafficByCountryCode = SimilarWebRestApiService.getCountryAndTrafficFromWebsite(correctedUrl, supportedCountryCodeByName, unsupportedCountryCodeByName);

        lead.GEOText__c = mapOfTrafficByCountryCode.get('valueOfSupportedGeoField');
        lead.Traffic__c = mapOfTrafficByCountryCode.get('valueOfSupportedTraffic') != null ? Decimal.valueOf(mapOfTrafficByCountryCode.get('valueOfSupportedTraffic')) : 0;
        lead.Other_GEO__c = mapOfTrafficByCountryCode.get('valueOfUnsupportedGeoField');
        lead.General_Traffic__c = mapOfTrafficByCountryCode.get('valueOfGeneralTraffic') != null ? Decimal.valueOf(mapOfTrafficByCountryCode.get('valueOfGeneralTraffic')) : 0;

        return lead;
    }
}