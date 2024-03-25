@IsTest
private class NodaHubRestServiceTest {

    @IsTest
    static void getNodaSettingsShouldReturn200() {
        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());

        TestDataFactory.createIntegrationSettings();

        RestRequest request = new RestRequest();
        request.addHeader('Content-Type', 'application/json');
        request.addHeader('api-key', TestConstants.INTEGRATION_KEY);
        request.httpMethod = TestConstants.GET;
        request.addParameter(ConstantUtility.OBJECT_NAME, ConstantUtility.LEAD);
        request.addParameter(ConstantUtility.FIELD_NAME, TestConstants.TEST_PRODUCT);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        NodaHubRestService.getNodaSettings();
        Test.stopTest();

        Assert.areEqual(200, RestContext.response.statusCode);

    }

    @IsTest
    static void getNodaSettingsShouldReturn404() {
        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());

        TestDataFactory.createIntegrationSettings();

        RestRequest request = new RestRequest();
        request.addHeader('Content-Type', 'application/json');
        request.addHeader('api-key', TestConstants.INTEGRATION_KEY);
        request.httpMethod = TestConstants.GET;
        request.addParameter(ConstantUtility.OBJECT_NAME, TestConstants.TEST_OBJECT);
        request.addParameter(ConstantUtility.FIELD_NAME, TestConstants.TEST_FIELD);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        NodaHubRestService.getNodaSettings();
        Test.stopTest();

        Assert.areEqual(404, RestContext.response.statusCode);
    }

    @IsTest
    static void getNodaSettingsShouldReturn401() {
        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());

        TestDataFactory.createIntegrationSettings();

        RestRequest request = new RestRequest();
        request.addHeader('Content-Type', 'application/json');
        request.httpMethod = TestConstants.GET;
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        NodaHubRestService.getNodaSettings();
        Test.stopTest();

        Assert.areEqual(401, RestContext.response.statusCode);
    }
}