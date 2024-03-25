public with sharing class OpportunityTriggerHandler extends TriggerHandler {
    
    public override void afterInsert() {
        Map<Id, Map<String,String>> accountIdByChangedStage = new Map<Id, Map<String,String>>();

        for (Opportunity opportunity : (List<Opportunity>) Trigger.new) {
            if (opportunity.Service_Type__c != null && opportunity.StageName != null) {
                if (!accountIdByChangedStage.containsKey(opportunity.AccountId)) {
                    accountIdByChangedStage.put(opportunity.AccountId, new Map<String, String>());
                }
                accountIdByChangedStage.get(opportunity.AccountId).put(opportunity.Service_Type__c, opportunity.StageName);
            }
        }

        if (!accountIdByChangedStage.isEmpty()) {
            OpportunityService.updateProductStatusOnAccount(accountIdByChangedStage);
        }
    }

    public override void afterUpdate() {
        Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>) Trigger.oldMap;
        Map<Id, Opportunity> newMap = (Map<Id, Opportunity>) Trigger.newMap;
        Map<Id, Map<String,String>> accountIdByChangedStage = new Map<Id, Map<String,String>>();
        Noda_Custom_Settings__c settingsOfNoda = SettingUtils.settingsOfNoda;

        for (Opportunity opportunity : newMap.values()) {
            if (opportunity.StageName != oldMap.get(opportunity.Id).StageName && opportunity.Service_Type__c != null) {
                if (!accountIdByChangedStage.containsKey(opportunity.AccountId)) {
                    accountIdByChangedStage.put(opportunity.AccountId, new Map<String, String>());
                }
                accountIdByChangedStage.get(opportunity.AccountId).put(opportunity.Service_Type__c, opportunity.StageName);
            }
        }

        if (!accountIdByChangedStage.isEmpty()) {
            OpportunityService.updateProductStatusOnAccount(accountIdByChangedStage);
        }
    }

}