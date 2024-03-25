public with sharing class SlackNotificationRestService {
    public static void sendMessageToSlack(String message) {
        Slack_Configuration__c slackConfig = SettingUtils.slackConfig;

        Map<String, Object> responseData = new Map<String, Object>{
            'channel' => slackConfig.Channel_Name__c,
            'text' => message
        };

        HttpRequest request = setHttpRequest(slackConfig, responseData);

        HttpRequestService.sendRequest(request);
    }

    public static void sendMessageToDigitalLeadSlack(String message) {
        Slack_Configuration__c slackConfig = SettingUtils.slackConfig;

        Map<String, Object> responseData = new Map<String, Object>{
            'channel' => slackConfig.Digital_Lead_Channel__c,
            'text' => message
        };

        HttpRequest request = setHttpRequest(slackConfig, responseData);

        HttpRequestService.sendRequest(request);
    }

    private static HttpRequest setHttpRequest(Slack_Configuration__c slackConfig, Map<String, Object> responseData) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(slackConfig.Post_Message_URL__c);
        request.setMethod('POST');
        request.setHeader('User-Agent', 'Salesforce');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + slackConfig.Bot_Token__c);
        request.setBody(JSON.serialize(responseData));

        return request;
    }
}