public class TaskTriggerHandler {
    
    public void onAfterInsert( List<Task> listOfNewTask){
        updateActivityDateForLeadWhenTaskCreated(listOfNewTask);
    }

    public void onAfterUpdate( Map<Id,Task> oldMap, Map<Id,Task> newMap){

        List<Task> listOfUpdatedTask = new List<Task> ();
        for(Task task:newMap.values()){
            if(task.ActivityDate != oldMap.get(task.Id).ActivityDate){
                listOfUpdatedTask.add(task);
            }
        }
        updateActivityDateForLeadWhenTaskCreated(listOfUpdatedTask);
    }

    public void onAfterDelete( List<Task> listOfOldTask){
        updateActivityDateForLeadWhenTaskDeleted(listOfOldTask);
    }

    public static void updateActivityDateForLeadWhenTaskCreated(List<Task> listOfNewTask) {

        Map<Id, Date> mapOfIdByActivityDate = new Map<Id, Date>();

        for (Task task : listOfNewTask) {
            if(task.WhoId != null) {
                if (task.WhoId.getSObjectType() == Lead.sObjectType) {
                    if(task.ActivityDate != null) {
                        mapOfIdByActivityDate.put(task.WhoId, task.ActivityDate);
                    }
                }
            }
        }
            List<Lead> listOfLeads = [SELECT Id, Activity_Date__c FROM Lead WHERE Id IN :mapOfIdByActivityDate.keySet()];
            for(Lead lead : listOfLeads) {
                Date activityDateOfTask = mapOfIdByActivityDate.get(lead.Id);
                if(lead.Activity_Date__c == null) {
                    lead.Activity_Date__c = activityDateOfTask;
                } else {
                    if(lead.Activity_Date__c < activityDateOfTask) {
                        lead.Activity_Date__c = activityDateOfTask;
                    }
                }
            }
            update listOfLeads;
    }

    public static void updateActivityDateForLeadWhenTaskDeleted(List<Task> listOfOldTask) {

        Map<Id, Date> mapOfIdByActivityDate = new Map<Id, Date>();
        Set<Id> setOfLeadIds = new Set<Id>();

        for (Task task : listOfOldTask) {
            if(task.WhoId != null) {
                if (task.WhoId.getSObjectType() == Lead.sObjectType) {
                    setOfLeadIds.add(task.WhoId);
                }
            }
        }
        if (!setOfLeadIds.isEmpty()) {
            Map<Id, Task> leadToLastTaskMap = new Map<Id, Task>();
    
            for (Task task : [SELECT WhoId, ActivityDate FROM Task WHERE WhoId IN :setOfLeadIds AND ActivityDate != null ORDER BY ActivityDate DESC]) {
                if (!leadToLastTaskMap.containsKey(task.WhoId)) {
                    leadToLastTaskMap.put(task.WhoId, task);
                }
            }

            List<Lead> leadsToUpdate = new List<Lead>();
            for (Id leadId : setOfLeadIds) {
                if (leadToLastTaskMap.containsKey(leadId)) {
                    leadsToUpdate.add(new Lead(Id = leadId, Activity_Date__c = leadToLastTaskMap.get(leadId).ActivityDate));
                } else {
                    leadsToUpdate.add(new Lead(Id = leadId, Activity_Date__c = null));
                }
            }
            if (!leadsToUpdate.isEmpty()) {
                update leadsToUpdate;
            }
        }
    }
}