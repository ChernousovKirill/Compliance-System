@IsTest
private class HttpRequestServiceTest {
    @IsTest
    static void testBehaviorStatus200() {
        HttpResponseGeneratorMock calloutMock = new HttpResponseGeneratorMock();

        calloutMock.responses.addAll(
            TestMock.getMockCallouts(
                new List<TestMock.ResponseType>{
                    TestMock.ResponseType.TEST_REQUEST_200
                }
            )
        );

        Test.setMock(HttpCalloutMock.class, calloutMock);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(TestMock.END_POINT_DEFAULT);
        request.setMethod(TestConstants.POST);
        request.setHeader(TestConstants.CONTENT_TYPE, TestConstants.APPLICATION_JSON);
        request.setBody(JSON.serialize(TestMock.RESPONSE_BODY_EMPTY));

        Test.startTest();
        HttpResponse result = HttpRequestService.sendRequest(request);
        Test.stopTest();

        Assert.areEqual(TestMock.STATUS_CODE_200, result.getStatusCode());
    }

    @IsTest
    static void testBehaviorStatus200WithError() {
        HttpResponseGeneratorMock calloutMock = new HttpResponseGeneratorMock();

        calloutMock.responses.addAll(
            TestMock.getMockCallouts(
                new List<TestMock.ResponseType>{
                    TestMock.ResponseType.TEST_REQUEST_200_WITH_ERROR
                }
            )
        );

        Test.setMock(HttpCalloutMock.class, calloutMock);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(TestMock.END_POINT_DEFAULT);
        request.setMethod(TestConstants.POST);
        request.setHeader(TestConstants.CONTENT_TYPE, TestConstants.APPLICATION_JSON);
        request.setBody(JSON.serialize(TestMock.RESPONSE_BODY_EMPTY));

        Test.startTest();
        HttpResponse result = HttpRequestService.sendRequest(request);
        Test.stopTest();

        Assert.areEqual(TestMock.STATUS_CODE_200, result.getStatusCode());
    }

    @IsTest
    static void testBehaviorStatus400() {
        HttpResponseGeneratorMock calloutMock = new HttpResponseGeneratorMock();

        calloutMock.responses.addAll(
            TestMock.getMockCallouts(
                new List<TestMock.ResponseType>{
                    TestMock.ResponseType.TEST_REQUEST_400
                }
            )
        );

        Test.setMock(HttpCalloutMock.class, calloutMock);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(TestMock.END_POINT_DEFAULT);
        request.setMethod(TestConstants.POST);
        request.setHeader(TestConstants.CONTENT_TYPE, TestConstants.APPLICATION_JSON);
        request.setBody(JSON.serialize(TestMock.RESPONSE_BODY_EMPTY));

        Test.startTest();
        HttpResponse result = HttpRequestService.sendRequest(request);
        Test.stopTest();

        Assert.areEqual(TestMock.STATUS_CODE_400, result.getStatusCode());
    }
}