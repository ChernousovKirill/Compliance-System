public without sharing class LeadTriggerHandler extends TriggerHandler {
    @TestVisible
    private static final Integer batchSize = 50;

    public override void beforeInsert() {
        List<Lead> listOfDigitalLeads = new List<Lead>();

        for (Lead lead : (List<Lead>) Trigger.new) {
            if ((lead.PrefferedServices__c != null && lead.PrefferedServices__c.contains(ConstantUtility.CARDS_PROCESSING)) || (lead.Product__c != null && lead.Product__c.contains(ConstantUtility.CARDS_PROCESSING))) {
                lead.Lead_with_Card_Process__c = true;
            }

            if (lead.LeadSource == 'Digital Marketing') {
                listOfDigitalLeads.add(lead);
            }

            if (!listOfDigitalLeads.isEmpty()) {
                LeadService.asignDigitalLeadManagers(listOfDigitalLeads);
            }
    
        }


    }

    public override void afterInsert() {
        Set<Id> setOfIds = new Set<Id>();
        List<Lead> listOfDigitalLeads = new List<Lead>();

        for (Lead lead : (List<Lead>) Trigger.new) {
            if (lead.Website != null && lead.LeadSource != 'Digital Marketing') {
                setOfIds.add(lead.Id);
            }
            if (lead.LeadSource == 'Digital Marketing') {
                listOfDigitalLeads.add(lead);
            }
        }

        if (!setOfIds.isEmpty()) {
            UpdateLeadsBatch shn = new UpdateLeadsBatch(setOfIds);
            Database.executeBatch(shn, batchSize);
        }

        if (!listOfDigitalLeads.isEmpty()) {
            LeadService.createCallTask(listOfDigitalLeads);
            LeadService.sendEmailForManagers(listOfDigitalLeads);
        }
    }


    public override void beforeUpdate() {
        Map<Id, Lead> newMap = (Map<Id, Lead>) Trigger.newMap;
        Map<Id, Lead> oldMap = (Map<Id, Lead>) Trigger.oldMap;
        Set<Id> setOfIds = new Set<Id>();

        for (Lead lead : newMap.values()) {
            if (lead.Website != oldMap.get(lead.Id).Website && (lead.Website != null || lead.Website != '')) {
                setOfIds.add(lead.Id);
            }
        }

        if (!setOfIds.isEmpty()) {
            UpdateLeadsBatch shn = new UpdateLeadsBatch(setOfIds);
            Database.executeBatch(shn, batchSize);
        }
    }
}