public class LogService {

    public static void saveApexLog (String name, String type, Datetime startDateTime){

        Database.insert(getApexLogForInsert(name, type, startDateTime), false);

    }

    @AuraEnabled
    public static void saveLWCLog(String id, String description) {
        Database.insert(getLWCLogForInsert(id, description));
    }

    public static Log__c getApexLogForInsert (String name, String type, Datetime startDateTime){

        Log__c logForInsert = new Log__c(
                Name = name,
                Type__c = type,
                Start_Date_Time__c = startDateTime
        );

        return logForInsert;
    }

    public static Log__c getLWCLogForInsert(String id, String description) {
        Log__c logForInsert = new Log__c(
                Name = 'Error ' + id,
                Type__c = ConstantUtility.LWC_ERROR,
                Description__c = description
        );

        return logForInsert;

    }

    public static void updateApexLogWhenBackupIsDone(String unicodeOfEmoji, String description, Integer size) {
        String today = '%' + Datetime.now().format('yyyy-MM-dd') + '%';

        Log__c logForUpdate = [SELECT Id, Name, End_Date_Time__c, Description__c, Size__c FROM Log__c WHERE  Name LIKE :today  LIMIT 1];

        logForUpdate.Name += unicodeOfEmoji;
        logForUpdate.End_Date_Time__c = Datetime.now();
        logForUpdate.Description__c = description;
        logForUpdate.Size__c = size;

        update logForUpdate;
    }
}