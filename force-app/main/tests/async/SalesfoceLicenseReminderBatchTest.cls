@isTest
private class SalesfoceLicenseReminderBatchTest {
    
    @isTest
    static void testScheduleJob() {
        SalesfoceLicenseReminderBatch batchInstance = new SalesfoceLicenseReminderBatch();
        
        String jobId = batchInstance.scheduleJob();
        
        System.assertNotEquals(null, jobId, 'JobId should not be null');
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();

        Test.setMock(Database.BatchableContext.class, new TestBatchableContext());
        TestDataFactory.createSlackConfiguration();
        SalesfoceLicenseReminderBatch batchInstance = new SalesfoceLicenseReminderBatch();
        Database.executeBatch(batchInstance);
        
        Test.stopTest();
        
        System.assertEquals(1, [SELECT count() FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status = 'Completed']);
    }
    
    private class TestBatchableContext implements Database.BatchableContext {
        public Iterable<sObject> start(Database.BatchableContext BC) {
            return [SELECT Id, Name, TotalLicenses, UsedLicenses FROM UserLicense WHERE Name = 'Salesforce' LIMIT 1];
        }
        
        public Id getJobId() {
            return '707XXXXXXXXXX'; // Dummy job ID
        }
        
        public Id getChildJobId() {
            return '707XXXXXXXXXX'; // Dummy child job ID
        }
    }
}
