public class CustomerTriggerHandler {

    public void onBeforeUpdate(Map<Id,Customer__c> oldMap, Map<Id,Customer__c> newMap) {

        Set<Id> setOfApprovedOrRejectedId = new Set<Id>();

        for(Customer__c customer : newMap.values()) {

            if(customer.Status__c != oldMap.get(customer.Id).Status__c) {
                if(customer.Status__c == ConstantUtility.ONBOARDING_STATUS) {
                    customer.Review_Started__c = System.today();
                }
                if(customer.Status__c == ConstantUtility.SENT_TO_APPROVE_STATUS) {
                    customer.Review_Completed__c = System.today();
                }
                if(customer.Status__c == ConstantUtility.ACTIVE_STATUS || customer.Status__c == ConstantUtility.REJECTED_STATUS) {
                    customer.Approved_by__c = customer.Approver_Position__c;
                    customer.Name_Surname__c = customer.Approver__c;
                }
            }
            if(customer.AML_Risk_Level__c != oldMap.get(customer.Id).AML_Risk_Level__c || customer.Score__c != oldMap.get(customer.Id).Score__c) {
                customer.AML_Risk_Matrix_ver__c = getAMLRiskVersion();
            }
        }
    }

    public static String getAMLRiskVersion() {

        return [SELECT Id, AML_Tool_Version__c FROM Form_Setting__c WHERE Form_Type__c = :ConstantUtility.AML_RISK_LEVEL AND Active__c = TRUE].AML_Tool_Version__c;
    }
}