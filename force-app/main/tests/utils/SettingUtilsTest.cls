@IsTest
private class SettingUtilsTest {
    @IsTest
    static void testBehavior() {
        TestDataFactory.createNodaCustomSetting();

        Noda_Custom_Settings__c settingsOfNoda = Noda_Custom_Settings__c.getOrgDefaults();
        Noda_Custom_Settings__c result = SettingUtils.settingsOfNoda;

        Assert.areEqual(settingsOfNoda.Name, result.Name);
        Assert.areEqual(settingsOfNoda.Domainst_Black_List__c, result.Domainst_Black_List__c);
        Assert.areEqual(settingsOfNoda.Org_URL__c, result.Org_URL__c);
        Assert.areEqual(settingsOfNoda.Jira_Api_Token__c, result.Jira_Api_Token__c);
        Assert.areEqual(settingsOfNoda.Jira_Project_Key__c, result.Jira_Project_Key__c);
        Assert.areEqual(settingsOfNoda.Jira_Url__c, result.Jira_Url__c);
        Assert.areEqual(settingsOfNoda.Jira_Username__c, result.Jira_Username__c);
        Assert.areEqual(settingsOfNoda.Standard_Opportunity__c, result.Standard_Opportunity__c);
        Assert.areEqual(settingsOfNoda.Upsale_Opportunity__c, result.Upsale_Opportunity__c);
    }

    @IsTest
    static void testBehavior2() {
        Noda_Custom_Settings__c settingsOfNoda = Noda_Custom_Settings__c.getOrgDefaults();
        Noda_Custom_Settings__c result = SettingUtils.settingsOfNoda;

        Assert.isNull(result.Name);
        Assert.isNull(result.Domainst_Black_List__c);
        Assert.isNull(result.Org_URL__c);
        Assert.isNull(result.Jira_Api_Token__c);
        Assert.isNull(result.Jira_Project_Key__c);
        Assert.isNull(result.Jira_Url__c);
        Assert.isNull(result.Jira_Username__c);
        Assert.isNull(result.Standard_Opportunity__c);
        Assert.isNull(result.Upsale_Opportunity__c);
        Assert.areEqual(settingsOfNoda.Name, result.Name);
        Assert.areEqual(settingsOfNoda.Domainst_Black_List__c, result.Domainst_Black_List__c);
        Assert.areEqual(settingsOfNoda.Org_URL__c, result.Org_URL__c);
        Assert.areEqual(settingsOfNoda.Jira_Api_Token__c, result.Jira_Api_Token__c);
        Assert.areEqual(settingsOfNoda.Jira_Project_Key__c, result.Jira_Project_Key__c);
        Assert.areEqual(settingsOfNoda.Jira_Url__c, result.Jira_Url__c);
        Assert.areEqual(settingsOfNoda.Jira_Username__c, result.Jira_Username__c);
        Assert.areEqual(settingsOfNoda.Standard_Opportunity__c, result.Standard_Opportunity__c);
        Assert.areEqual(settingsOfNoda.Upsale_Opportunity__c, result.Upsale_Opportunity__c);
    }

    @IsTest
    static void slackConfig() {
        TestDataFactory.createSlackConfiguration();

        Slack_Configuration__c slackConfig = Slack_Configuration__c.getOrgDefaults();
        Slack_Configuration__c result = SettingUtils.slackConfig;

        Assert.areEqual(slackConfig.Name, result.Name);
        Assert.areEqual(slackConfig.Post_Message_URL__c, result.Post_Message_URL__c);
        Assert.areEqual(slackConfig.Bot_Token__c, result.Bot_Token__c);
        Assert.areEqual(slackConfig.Channel_Name__c, result.Channel_Name__c);
    }

    @IsTest
    static void slackConfig2() {
        Slack_Configuration__c slackConfig = Slack_Configuration__c.getOrgDefaults();
        Slack_Configuration__c result = SettingUtils.slackConfig;

        Assert.isNull(result.Name);
        Assert.isNull(result.Post_Message_URL__c);
        Assert.isNull(result.Bot_Token__c);
        Assert.isNull(result.Channel_Name__c);
        Assert.areEqual(slackConfig.Name, result.Name);
        Assert.areEqual(slackConfig.Post_Message_URL__c, result.Post_Message_URL__c);
        Assert.areEqual(slackConfig.Bot_Token__c, result.Bot_Token__c);
        Assert.areEqual(slackConfig.Channel_Name__c, result.Channel_Name__c);
    }

    @IsTest
    static void integrationSettings() {
        TestDataFactory.createIntegrationSettings();

        Integration_Settings__c settings = Integration_Settings__c.getInstance();
        Integration_Settings__c result = SettingUtils.integrationSettings;

        Assert.areEqual(settings.Google_Form_Api_Key__c, result.Google_Form_Api_Key__c);
    }

    @IsTest
    static void integrationSettings2() {
        Integration_Settings__c settings = Integration_Settings__c.getInstance();
        Integration_Settings__c result = SettingUtils.integrationSettings;

        Assert.isNull(result.Google_Form_Api_Key__c);
        Assert.areEqual(settings.Google_Form_Api_Key__c, result.Google_Form_Api_Key__c);
    }
}