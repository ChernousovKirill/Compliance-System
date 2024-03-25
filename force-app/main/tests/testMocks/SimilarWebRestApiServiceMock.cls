@isTest
global class SimilarWebRestApiServiceMock implements HttpCalloutMock {
        
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse reponse = new HttpResponse();
        reponse.setHeader('Content-Type', 'application/json');
        if (req.getEndpoint().contains('geo/total-traffic-by-country')) {
            // Simulate a successful response for getCountryAndTrafficFromWebsite()
            reponse.setStatusCode(200);
            reponse.setBody('{"records": [{"country_name": "'+ TestConstants.US_COUNTRY_NAME +'", "visits": ' + TestConstants.US_VISITS + '}, {"country_name": "'+ TestConstants.FRANCE_COUNTRY_NAME +'", "visits": '+ TestConstants.FRANCE_VISITS +'}]}');
        } else if (req.getEndpoint().contains('category-rank/category-rank')) {
            // Simulate a successful response for getIndustryOfWebsite()
            reponse.setStatusCode(200);
            reponse.setBody('{"category": "' + TestConstants.SOME_CATEGORY_LEAD_INDUSTRY + '"}');
        } else {
            // Simulate an error response for unknown endpoints
            reponse.setStatusCode(404);
        }
        return reponse;
    }
}