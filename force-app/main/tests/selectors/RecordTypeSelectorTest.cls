@IsTest
private class RecordTypeSelectorTest {
    @IsTest
    static void getAccounts() {
        RecordType rType = [SELECT Id, Name FROM RecordType][0];

        Test.startTest();
        Id result = RecordTypeSelector.getRecordTypeIdByName(rType.Name);
        Test.stopTest();

        Assert.areEqual(rType.Id, result);
    }

}