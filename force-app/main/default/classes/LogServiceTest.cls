@isTest
public class LogServiceTest {

    @isTest
    public static void testSaveApexLog() {
        // Create test data
        String nameOfLog = 'Test Apex Log';
        String typeOfLog = 'Error';
        Datetime startDateTimeOfLog = Datetime.newInstance(2023, 7, 24, 12, 0, 0);
        String descriptionOfLog = 'Test descriptionOfLog';

        // Call the method being tested
        Test.startTest();
        LogService.saveApexLog(nameOfLog, typeOfLog, startDateTimeOfLog, descriptionOfLog);
        Test.stopTest();

        // Verify that the record has been inserted correctly
        List<Log__c> logs = [SELECT Id, Name, Type__c, Start_Date_Time__c, Description__c FROM Log__c];
        System.assertEquals(1, logs.size());
        Log__c log = logs[0];
        System.assertEquals(nameOfLog, log.Name);
        System.assertEquals(typeOfLog, log.Type__c);
        System.assertEquals(startDateTimeOfLog, log.Start_Date_Time__c);
        System.assertEquals(descriptionOfLog, log.Description__c);
    }

    @isTest
    public static void testSaveLWCLog() {

        String id = '0007';
        String descriptionOfLog = 'Test LWC log description';

        // Call the method being tested
        Test.startTest();
        LogService.saveLWCLog(id, descriptionOfLog);
        Test.stopTest();

        // Verify that the record has been inserted correctly
        List<Log__c> logs = [SELECT Id, Name, Type__c, Description__c FROM Log__c];
        System.assertEquals(1, logs.size());
        Log__c log = logs[0];
        System.assertEquals('Error ' + id, log.Name);
        System.assertEquals(ConstantUtility.LWC_ERROR, log.Type__c);
        System.assertEquals(descriptionOfLog, log.Description__c);
    }

    @isTest
    public static void testUpdateApexLogWhenBackupIsDone() {
        // Create test data
        String emoji = '\uD83C\uDF89';
        String descriptionOfLog = 'Backup is complete';
        Integer size = 1024;

        // Create a test record for update
        Log__c log = new Log__c(Name = 'Test Log ' +  Datetime.now().format('yyyy-MM-dd'), Type__c = 'Backup', Start_Date_Time__c = Datetime.now(), Description__c = 'Test Description');

        // Insert the test record
        insert log;

        // Add some debug statements to help identify the issue
        System.debug('Number of Logs before updateApexLogWhenBackupIsDone: ' + [SELECT COUNT() FROM Log__c]);

        // Call the method being tested
        Test.startTest();
        LogService.updateApexLogWhenBackupIsDone(emoji, descriptionOfLog, size);
        Test.stopTest();

        // Verify that the record has been updated correctly
        Log__c updatedLog = [SELECT Id, Name, End_Date_Time__c, Description__c, Size__c FROM Log__c WHERE Id = :log.Id];
        System.assertEquals('Test Log ' +Datetime.now().format('yyyy-MM-dd') + emoji, updatedLog.Name);
        System.assertNotEquals(null, updatedLog.End_Date_Time__c);
        System.assertEquals(descriptionOfLog, updatedLog.Description__c);
        System.assertEquals(size, updatedLog.Size__c);
    }


    @isTest
    public static void testGetApexLogForInsert() {
        // Call the method being tested
        Log__c log = LogService.getApexLogForInsert('Test Name', 'Error', Datetime.now(), 'Test Description');

        // Verify that the returned Log__c instance has the correct values
        System.assertEquals('Test Name', log.Name);
        System.assertEquals('Error', log.Type__c);
        System.assertNotEquals(null, log.Start_Date_Time__c);
        System.assertEquals('Test Description', log.Description__c);
    }
}
