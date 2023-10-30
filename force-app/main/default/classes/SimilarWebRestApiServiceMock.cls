@isTest
global class SimilarWebRestApiServiceMock implements HttpCalloutMock {
        
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse reponse = new HttpResponse();
        reponse.setHeader('Content-Type', 'application/json');
        if (req.getEndpoint().contains('geo/total-traffic-by-country')) {
            // Simulate a successful response for getCountryAndTrafficFromWebsite()
            reponse.setStatusCode(200);
            reponse.setBody('{"records": [{"country_name": "United States", "visits": 100}, {"country_name": "France", "visits": 150}]}');
        } else if (req.getEndpoint().contains('category-rank/category-rank')) {
            // Simulate a successful response for getIndustryOfWebsite()
            reponse.setStatusCode(200);
            reponse.setBody('{"category": "Some_Category"}');
        } else {
            // Simulate an error response for unknown endpoints
            reponse.setStatusCode(404);
        }
        return reponse;
    }
}