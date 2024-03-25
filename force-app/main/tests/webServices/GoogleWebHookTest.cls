@IsTest
private class GoogleWebHookTest {
    private static final String KEY = TestConstants.INTEGRATION_KEY;
    private static final String EMAIL = 'example@com.com';
    private static final String PHONE = '11-11';
    private static final String COMPANY_NAME = 'companyName';
    private static final String REQUEST_BODY_JSON = '{\n' +
        '    "id": "0",\n' +
        '    "name": "contact",\n' +
        '    "referrer": "' + TestConstants.TEST_SITE_URL + '",\n' +
        '    "data": {\n' +
        '        "name": "' + TestConstants.TEST_NAME + '",\n' +
        '        "surname": "' + TestConstants.TEST_NAME + '",\n' +
        '        "email": "' + EMAIL + '",\n' +
        '        "phone": "' + PHONE+ '",\n' +
        '        "companyName": "' + COMPANY_NAME + '",\n' +
        '        "website": "' + TestConstants.TEST_SITE_URL + '",\n' +
        '        "companySize": 1,\n' +
        '        "country": "BE",\n' +
        '        "paymentsVolume": 1,\n' +
        '        "comment": "test",\n' +
        '        "preferredServices": []\n' +
        '    },\n' +
        '    "advTags": {\n' +
        '        "utm_source": "utm_source",\n' +
        '        "utm_medium": "utm_medium",\n' +
        '        "utm_campaign": "utm_campaign",\n' +
        '        "utm_content": "utm_content",\n' +
        '        "utm_term": "utm_term",\n' +
        '        "customclid": "customclid",\n' +
        '        "gclid": "gclid"\n' +
        '    }\n' +
        '}';

    @IsTest
    static void successLeadCreated() {
        TestDataFactory.createIntegrationSettings();
        TestDataFactory.createSlackConfiguration();
        TestDataFactory.createNodaCustomSetting();

        RestRequest request = new RestRequest();
        request.addHeader('Content-Type', 'application/json');
        request.addHeader('api-key', KEY);
        request.requestBody = Blob.valueOf(REQUEST_BODY_JSON);
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = new RestResponse();

        GoogleWebHook.send();

        Assert.areEqual(200, RestContext.response.statusCode);
        Assert.isTrue((Boolean) ((Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString())).get('success'));

        Lead lead = [SELECT Company, Email, FirstName, Website FROM Lead LIMIT 1];

        Assert.areEqual(COMPANY_NAME, lead.Company);
        Assert.areEqual(EMAIL, lead.Email);
        Assert.areEqual(TestConstants.TEST_NAME, lead.FirstName);
        Assert.areEqual(TestConstants.TEST_SITE_URL, lead.Website);
    }

    @IsTest
    static void apiKeyNotSetted() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = new RestResponse();

        GoogleWebHook.send();

        Assert.areEqual(401, RestContext.response.statusCode);
        Assert.isFalse((Boolean) ((Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString())).get('success'));
    }

    @IsTest
    static void bodyIsEmpty() {
        TestDataFactory.createIntegrationSettings();

        RestRequest request = new RestRequest();
        request.addHeader('api-key', KEY);
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('');

        RestContext.request = request;
        RestContext.response = new RestResponse();

        GoogleWebHook.send();

        Assert.areEqual(400, RestContext.response.statusCode);
        Assert.isFalse((Boolean) ((Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString())).get('success'));
    }

    @IsTest
    static void successLeadCreatedWithCallSimilarWebService() {
        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());

        TestDataFactory.createIntegrationSettings();
        TestDataFactory.createSlackConfiguration();
        TestDataFactory.createNodaCustomSetting();

        RestRequest request = new RestRequest();
        request.addHeader('Content-Type', 'application/json');
        request.addHeader('api-key', KEY);
        request.requestBody = Blob.valueOf(REQUEST_BODY_JSON);
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        GoogleWebHook.send();
        Test.stopTest();

        Assert.areEqual(200, RestContext.response.statusCode);
        Assert.isTrue((Boolean) ((Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString())).get('success'));

        Lead lead = [SELECT Company, Website, General_Traffic__c FROM Lead LIMIT 1];

        Assert.areEqual(COMPANY_NAME, lead.Company);
        Assert.areEqual(TestConstants.TEST_SITE_URL, lead.Website);
        Assert.areEqual(TestConstants.US_VISITS + TestConstants.FRANCE_VISITS, lead.General_Traffic__c);
    }

    @IsTest
    static void getLeadStatus200() {
        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());

        Lead testLead = TestDataFactory.initLead(false);
        testLead.Email = TestConstants.TEST_EMAIL;
        testLead.Website = TestConstants.TEST_SITE_URL;

        insert testLead;

        TestDataFactory.createIntegrationSettings();

        RestRequest request = new RestRequest();
        request.addHeader('Content-Type', 'application/json');
        request.addHeader('api-key', KEY);
        request.httpMethod = TestConstants.GET;
        request.addParameter(ConstantUtility.EMAIL, TestConstants.TEST_EMAIL);
        request.addParameter(ConstantUtility.WEBSITE, TestConstants.TEST_SITE_URL);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        GoogleWebHook.getLead();
        Test.stopTest();

        Lead lead = [SELECT Email, Website FROM Lead LIMIT 1];

        Assert.areEqual(TestConstants.TEST_SITE_URL, lead.Website);
        Assert.areEqual(TestConstants.TEST_EMAIL , lead.Email);
    }

    @IsTest
    static void getLeadStatus404() {
        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());

        TestDataFactory.createIntegrationSettings();

        RestRequest request = new RestRequest();
        request.addHeader('Content-Type', 'application/json');
        request.addHeader('api-key', KEY);
        request.httpMethod = TestConstants.GET;
        request.addParameter(ConstantUtility.EMAIL, TestConstants.TEST_EMAIL);
        request.addParameter(ConstantUtility.WEBSITE, TestConstants.TEST_SITE_URL);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        GoogleWebHook.getLead();
        Test.stopTest();

        Assert.areEqual(404, RestContext.response.statusCode);
    }

    @IsTest
    static void getLeadShouldReturn401() {
        Test.setMock(HttpCalloutMock.class, new SimilarWebRestApiServiceMock());

        TestDataFactory.createIntegrationSettings();

        RestRequest request = new RestRequest();
        request.addHeader('Content-Type', 'application/json');
        request.httpMethod = TestConstants.GET;
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        GoogleWebHook.getLead();
        Test.stopTest();

        Assert.areEqual(401, RestContext.response.statusCode);
    }
}