public with sharing class HttpRequestService {
    public static Integration_Settings__c settings = SettingUtils.integrationSettings;

    public static HttpResponse sendRequest(HttpRequest request) {
        Map<Integer, String> errorMessagesByCode = new Map<Integer, String>();
        Http http = new Http();
        HttpResponse response;

        try {
            response = http.send(request);

            if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {

                Map<String, Object> responseBody = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());

                if (responseBody.get('error') != '' || responseBody.get('error') != null) {
                    errorMessagesByCode.put(response.getStatusCode(), String.valueOf(responseBody.get('error')));
                }
            } else {
                errorMessagesByCode.put(response.getStatusCode(), response.getBody());
            }

            if (!errorMessagesByCode.isEmpty()) {
                LoggerUtil.error('Http Request Error: ' + String.valueOf(errorMessagesByCode));
                LoggerUtil.saveLog();            }
        } catch (Exception e) {
            LoggerUtil.error('Http Request Error: ', e, true);
        }

        return response;
    }

    public static Boolean validateRequestHeader(Map<String, String> requestHeaders) {
        Boolean isNotValid = false;

        if (!requestHeaders.containsKey(ConstantUtility.API_KEY) || requestHeaders.get(ConstantUtility.API_KEY) != settings.Google_Form_Api_Key__c) {
            RestResponse response = RestContext.response;
            response.statusCode = 401;
            response.responseBody = Blob.valueOf(JSON.serialize(new Map <String, Object>{
                ConstantUtility.SUCCESS => false
            }));

            isNotValid = true;
        }

        return isNotValid;
    }

}