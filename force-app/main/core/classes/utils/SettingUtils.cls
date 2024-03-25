public with sharing class SettingUtils {
    public static Noda_Custom_Settings__c settingsOfNoda {
        get {
            if (settingsOfNoda == null) {
                settingsOfNoda = Noda_Custom_Settings__c.getOrgDefaults();
            }

            return settingsOfNoda;
        }
        set;
    }

    public static Slack_Configuration__c slackConfig {
        get {
            if (slackConfig == null) {
                slackConfig = Slack_Configuration__c.getOrgDefaults();
            }

            return slackConfig;
        }
        set;
    }

    public static Integration_Settings__c integrationSettings {
        get {
            if (integrationSettings == null) {
                integrationSettings = Integration_Settings__c.getInstance();
            }

            return integrationSettings;
        }
        set;
    }
}