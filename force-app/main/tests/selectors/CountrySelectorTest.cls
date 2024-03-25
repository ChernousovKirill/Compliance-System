@IsTest
private class CountrySelectorTest {
    private static final Integer NEW_RECORDS = 200;

    @TestSetup
    static void setup() {
        List<Country__c> countries = CountrySelector.getCountries();

        for (Integer i = 0; i<NEW_RECORDS; i++) {
            Country__c country = new Country__c(
                Name = 'countryName',
                Country_Code__c = 'countryCode',
                Is_country_with_supported_banks__c = true
            );

            countries.add(country);
        }

        insert countries;
    }

    @IsTest
    static void getCountries() {
        Test.startTest();
        List<Country__c> countries = CountrySelector.getCountries();
        Test.stopTest();

        Assert.areEqual(NEW_RECORDS, countries.size());
    }

    @IsTest
    static void getCountries2() {
        Test.startTest();
        List<Country__c> countries = CountrySelector.getCountriesForSimilarWebCall();

        Test.stopTest();

        Assert.areEqual(NEW_RECORDS, countries.size());
    }
}