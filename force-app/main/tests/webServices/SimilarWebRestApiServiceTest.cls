@isTest
public class SimilarWebRestApiServiceTest {

    @isTest
    static void testGetCountryAndTrafficFromWebsite() {
        // Prepare test data
        String urlOfWebsite = 'example.com';
        Map<String, String> mapOfSupportedCountryCodeByName = new Map<String, String>();
        mapOfSupportedCountryCodeByName.put('United States', 'US');
        Map<String, String> mapOfUnsupportedCountryCodeByName = new Map<String, String>();
        mapOfUnsupportedCountryCodeByName.put('France', 'FR');

        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());

        // Call the method to be tested
        Map<String, String> result = SimilarWebRestApiService.getCountryAndTrafficFromWebsite(
            urlOfWebsite, mapOfSupportedCountryCodeByName, mapOfUnsupportedCountryCodeByName
        );

        // Assert the results
        System.assertEquals('US;', result.get('valueOfSupportedGeoField'));
        System.assertEquals('100', result.get('valueOfSupportedTraffic'));
        System.assertEquals('FR;', result.get('valueOfUnsupportedGeoField'));
        System.assertEquals('250', result.get('valueOfGeneralTraffic'));
    }

    @isTest
    static void testGetIndustryOfWebsite() {
        // Prepare test data
        String urlOfWebsite = 'example.com';

        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());

        // Call the method to be tested
        String result = SimilarWebRestApiService.getIndustryOfWebsite(urlOfWebsite);

        // Assert the result
        System.assertEquals('Some Category', result);
    }
}