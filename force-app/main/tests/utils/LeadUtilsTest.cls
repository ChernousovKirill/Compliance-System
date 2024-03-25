@IsTest
private class LeadUtilsTest {
    @IsTest
    static void updateIndustryOfLeadShouldUpdateIndustryField() {
        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());
        Lead newLead = initLead();

        Assert.isNull(newLead.Industry__c);

        Test.startTest();
        Lead result = new LeadUtils().updateIndustryOfLead(newLead);
        Test.stopTest();

        Assert.isNotNull(result.Industry__c);
    }

    @IsTest
    static void updateIndustryOfLeadShouldThrowError() {
        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());
        Lead newLead = new Lead();
        Boolean isError = false;

        try {
            Test.startTest();
            new LeadUtils().updateIndustryOfLead(newLead);
            Test.stopTest();
        } catch (Exception e) {
            isError = true;

        }

        Assert.isTrue(isError);
    }

    @IsTest
    static void updateTrafficOfLeadShouldUpdateLead() {
        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());

        Lead newLead = initLead();

        Test.startTest();
        Lead result = new LeadUtils().updateTrafficOfLead(newLead, new Map<Boolean, Map<String, String>> ());
        Test.stopTest();

        Assert.isNull(result.GEOText__c);
        Assert.isNull(result.Other_GEO__c);
        Assert.areEqual(0, result.Traffic__c);
        Assert.areEqual(0, result.General_Traffic__c);
    }

    @IsTest
    static void updateTrafficOfLeadShouldUpdateLead2() {
        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());
        Map<Boolean, Map<String, String>> isSupportedBanksToCountryNameCountryCode = new CountryUtils().getCountryCodeOfSupportedCountries();

        Lead newLead = initLead();

        Test.startTest();
        Lead result = new LeadUtils().updateTrafficOfLead(newLead, isSupportedBanksToCountryNameCountryCode);
        Test.stopTest();

        Assert.areEqual(0, result.Traffic__c);
        Assert.areEqual(250, result.General_Traffic__c);
    }


    @IsTest
    static void updateTrafficOfLeadShouldUpdateLead3() {
        initCountry(TestConstants.US_COUNTRY_NAME, TestConstants.US_COUNTRY_CODE, true, true);

        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());
        Map<Boolean, Map<String, String>> isSupportedBanksToCountryNameCountryCode = new CountryUtils().getCountryCodeOfSupportedCountries();

        Lead newLead = initLead();

        Test.startTest();
        Lead result = new LeadUtils().updateTrafficOfLead(newLead, isSupportedBanksToCountryNameCountryCode);
        Test.stopTest();

        Assert.isTrue(result.GEOText__c.split(';').contains(TestConstants.US_COUNTRY_CODE));
        Assert.areEqual('', result.Other_GEO__c);
        Assert.areEqual(TestConstants.US_VISITS, result.Traffic__c);
        Assert.areEqual(TestConstants.US_VISITS + TestConstants.FRANCE_VISITS, result.General_Traffic__c);
    }

    static Lead initLead() {
        Lead ld = new Lead(
            FirstName = 'Name',
            LastName = 'Surname',
            Website = 'site.com'
        );

        return ld;
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