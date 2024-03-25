public inherited sharing class CountryUtils {
    public Map<Boolean, Map<String, String>> getCountryCodeOfSupportedCountries() {
        Map<Boolean, Map<String, String>> isSupportedBanksToCountryCodeByCountryName = new Map<Boolean, Map<String, String>>{
            true => new Map<String, String>(),
            false => new Map<String, String>()
        };

        List<Country__c> listOfCountries = CountrySelector.getCountriesForSimilarWebCall();

        for (Country__c country : listOfCountries) {
            Map<String, String> countryCodeByName = mapCountryNameToCountryCode(country);

            isSupportedBanksToCountryCodeByCountryName.get(country.Is_country_with_supported_banks__c).putAll(countryCodeByName);
        }

        return isSupportedBanksToCountryCodeByCountryName;
    }

    private Map<String, String> mapCountryNameToCountryCode(Country__c country) {
        Map<String, String> mapOfCountryCodeByName = new Map<String, String>();
        mapOfCountryCodeByName.put(country.Name, country.Country_Code__c);

        return mapOfCountryCodeByName;
    }
}