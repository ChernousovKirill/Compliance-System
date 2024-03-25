public with sharing class SobjectUtils {

    public static Map<String, String> getSobjectPickListValues(String objectName, String picklistField) {
        Map<String, String> picklistValues = new Map<String, String>();

        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        if (objectType != null) {
            Schema.DescribeSObjectResult objDescribeSobject = objectType.getDescribe();
            Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
            List<Schema.PicklistEntry> lstPickListValues = mapFields.get(picklistField).getDescribe().getPickListValues();

            for (Schema.PicklistEntry objPickList : lstPickListValues) {
                if (objPickList.isActive()) {
                    picklistValues.put(objPickList.getLabel(), objPickList.getValue());
                }
            }
        }

        return picklistValues;
    }

    public static String getFieldApiNameByLabel(String objectName, String fieldLabel) {
        String fieldName = '';
        
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        if (objectType != null) {
            Map<String, Schema.SObjectField> mapOfFields = objectType.getDescribe().fields.getMap();
    
            for (Schema.SObjectField field : mapOfFields.values()) {
                if (field.getDescribe().getLabel() == fieldLabel) {
                    fieldName = field.getDescribe().getName();
                }
            }
        }

        return fieldName;
    }
}