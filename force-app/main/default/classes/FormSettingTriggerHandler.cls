public class FormSettingTriggerHandler {

    public void onBeforeInsert(List<Form_Setting__c> listOfAMLFormSetting) {
        checkIsAMLFormSettingActive(listOfAMLFormSetting);
    }

    public void onBeforeUpdate(Map<Id,Form_Setting__c> oldMap, Map<Id,Form_Setting__c> newMap){
        
        List<Form_Setting__c> listOfAMLFormSetting = new List<Form_Setting__c>();
        for(Form_Setting__c formSetting : newMap.values()) {
            if(formSetting.Active__c != oldMap.get(formSetting.Id).Active__c && formSetting.Active__c == true) {
                listOfAMLFormSetting.add(formSetting);
            }
        }
        if(!listOfAMLFormSetting.isEmpty()) {
            checkIsAMLFormSettingActive(listOfAMLFormSetting);
        }
    }

    private void checkIsAMLFormSettingActive(List<Form_Setting__c> listOfAMLFormSetting) {
        
        List<Form_Setting__c> listOfActiveAMLFormSetting = [SELECT Id, Active__c, Form_Type__c 
                                                           FROM Form_Setting__c 
                                                           WHERE Active__c = TRUE 
                                                           AND Form_Type__c = : ConstantUtility.AML_RISK_LEVEL];

        if(!listOfActiveAMLFormSetting.isEmpty()) {
            for(Form_Setting__c amlFormSetting : listOfAMLFormSetting) {
                if(amlFormSetting.Active__c == true && amlFormSetting.Form_Type__c == ConstantUtility.AML_RISK_LEVEL) {
                    throw new FormSettingTriggerHandlerException(System.Label.oneAMLFormActiveLabel);
                }
            }
        }
    }

    private class FormSettingTriggerHandlerException extends Exception {}

}