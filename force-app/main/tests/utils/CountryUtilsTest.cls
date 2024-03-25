@IsTest
private class CountryUtilsTest {
    static void setup() {
        List<Country__c> countries = CountrySelector.getCountries();

        for (Integer i = 0; i<TestConstants.NEW_RECORDS; i++) {
            Country__c country = initCountry('test' + i, 'test' + i, Math.mod(i, 2) == 0, false);

            countries.add(country);
        }

        insert countries;
    }

    @IsTest
    static void getCountryCodeOfSupportedCountries() {
        setup();

        Test.startTest();
        Map<Boolean, Map<String, String>> result = new CountryUtils().getCountryCodeOfSupportedCountries();
        Test.stopTest();

        Assert.areEqual(2, result.keySet().size());
        Assert.areEqual(TestConstants.NEW_RECORDS / 2, result.get(true).size());
        Assert.areEqual(TestConstants.NEW_RECORDS / 2, result.get(false).size());
    }

    @IsTest
    static void getCountryCodeOfSupportedCountriesShouldReturnEmptyMap() {
        Test.startTest();
        Map<Boolean, Map<String, String>> result = new CountryUtils().getCountryCodeOfSupportedCountries();
        Test.stopTest();

        Assert.areEqual(2, result.keySet().size());
        Assert.areEqual(0, result.get(true).size());
        Assert.areEqual(0, result.get(false).size());
    }

    public static Country__c initCountry(String countryName, String countryCode, Boolean isSupportedBank, Boolean doInsert) {
        Country__c newCountry = new Country__c(
            Name = countryName,
            Country_Code__c = countryCode,
            Is_country_with_supported_banks__c = isSupportedBank
        );

        if (doInsert) {
            insert newCountry;
        }

        return newCountry;
    }
}