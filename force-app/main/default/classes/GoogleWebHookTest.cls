@IsTest
private class GoogleWebHookTest {
    private static final String key = 'key';
    @IsTest
    static void successLeadCreated() {
        Integration_Settings__c settings = new Integration_Settings__c(
                Google_Form_Api_Key__c = key
        );
        insert settings;

        GoogleWebHook.Data data = new GoogleWebHook.Data();
        data.name = 'name';
        data.surname = 'surname';
        data.companyName = 'comapny';
        GoogleWebHook.GoogleForm form = new GoogleWebHook.GoogleForm();
        form.data = data;

        RestRequest request = new RestRequest();
        request.addHeader('Content-Type', 'application/json');
        request.addHeader('api-key', key);
        request.requestBody = Blob.valueOf(JSON.serialize(form));
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = new RestResponse();

        GoogleWebHook.send();

        Assert.areEqual(200, RestContext.response.statusCode);
        Assert.isTrue((Boolean) ((Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString())).get('success'));

        Lead lead = [SELECT Company FROM Lead LIMIT 1];

        Assert.areEqual('comapny', lead.Company);
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
        Integration_Settings__c settings = new Integration_Settings__c(
                Google_Form_Api_Key__c = key
        );
        insert settings;

        RestRequest request = new RestRequest();
        request.addHeader('api-key', key);
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = new RestResponse();

        GoogleWebHook.send();

        Assert.areEqual(400, RestContext.response.statusCode);
        Assert.isFalse((Boolean) ((Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString())).get('success'));
    }
}