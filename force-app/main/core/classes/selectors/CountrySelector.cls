public inherited sharing class CountrySelector {
    public static List<Country__c> getCountries() {
        return  [
            SELECT Name, Incorporation_Country_Score__c, UBO_Citizenship_Score__c, UBO_Nationality_Score__c, UBO_Residence_Score__c
            FROM Country__c
            ORDER BY Name
        ];
    }

    public static List<Country__c> getCountriesForSimilarWebCall() {
        return  [
            SELECT Name, Country_Code__c, Is_country_with_supported_banks__c
            FROM Country__c
            ORDER BY Name
        ];
    }
}