public with sharing class SalesfoceLicenseReminderBatch implements Schedulable, Database.Batchable<sObject>, Database.AllowsCallouts {
    
    public String scheduledTime =  '0 0 1 1 * ?';
        
    public String scheduleJob() {
        SalesfoceLicenseReminderBatch objScheduler = new SalesfoceLicenseReminderBatch(); 
        String strJobName = Test.isRunningTest() ? 'SalesfoceLicenseReminderBatchTest' : 'SalesfoceLicenseReminderBatch';
        return System.schedule(strJobName, scheduledTime, objScheduler);
    }

    public void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(new SalesfoceLicenseReminderBatch());
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Name, TotalLicenses, UsedLicenses FROM UserLicense WHERE Name = \'Salesforce\'');
    }

    public void execute(Database.BatchableContext BC, List<UserLicense> userLicenses) {
        String amountOfAvailableLicense;
        String message;

        for (UserLicense userLicense : userLicenses) {
            amountOfAvailableLicense = countAvailableSalesfoceLicense(userLicense);
        }

        message = Label.weeklyLicenseReminder + ' ' + amountOfAvailableLicense;
        SlackNotificationRestService.sendMessageToSlack(message);
    }

    public void finish(Database.BatchableContext BC) {
    }

    private static String countAvailableSalesfoceLicense(UserLicense userLicense) {

        Integer amountOfAvailableLicense = userLicense.TotalLicenses - userLicense.UsedLicenses;

        return String.valueOf(amountOfAvailableLicense);
    }
}