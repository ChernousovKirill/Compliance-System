public with sharing class RecordTypeSelector {
    public static Id getRecordTypeIdByName(String nameOfRecordType) {
        return [
            SELECT Id
            FROM RecordType
            WHERE Name = :nameOfRecordType
        ]?.Id;
    }

    public static Map<String, Id> getRecordTypeNameToId(List<String> recordTypeNames) {
        List<RecordType> recordTypes = [
            SELECT Id, Name
            FROM RecordType
            WHERE Name IN :recordTypeNames
        ];

        Map<String, Id> nameById = new Map<String, Id>();

        for (RecordType rType : recordTypes) {
            nameById.put(rType.Name, rType.Id);
        }

        return nameById;
    }
}