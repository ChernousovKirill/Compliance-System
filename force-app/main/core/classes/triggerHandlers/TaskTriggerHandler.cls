public class TaskTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
        updateActivityDateForLeadWhenTaskCreated((List<Task>) Trigger.new);
    }

    public override void afterUpdate() {
        Map<Id, Task> taskByIdsNew = (Map<Id, Task>) Trigger.newMap;
        Map<Id, Task> taskByIdsOld = (Map<Id, Task>) Trigger.oldMap;
        List<Task> listOfUpdatedTask = getTasksWithChangedActivityDate(taskByIdsNew, taskByIdsOld);

        updateActivityDateForLeadWhenTaskCreated(listOfUpdatedTask);
    }

    public override void afterDelete() {
        updateActivityDateForLeadWhenTaskDeleted((List<Task>) Trigger.old);
    }

    private List<Task> getTasksWithChangedActivityDate(Map<Id, Task> taskByIdsNew, Map<Id, Task> taskByIdsOld) {
        List<Task> listOfUpdatedTask = new List<Task>();

        for (Task task : taskByIdsNew.values()) {
            if (task.ActivityDate != taskByIdsOld.get(task.Id).ActivityDate) {
                listOfUpdatedTask.add(task);
            }
        }

        return listOfUpdatedTask;
    }

    private void updateActivityDateForLeadWhenTaskCreated(List<Task> listOfNewTask) {
        Map<Id, Date> mapOfIdByActivityDate = getTaskWhoIdByActivityDate(listOfNewTask);
        Set<Id> setOfLeadIds = new Set<Id>();
        Set<Id> setOfAccountIds = new Set<Id>();
        List<Lead> listOfLeads = new List<Lead>();
        List<Account> listOfAccounts = new List<Account>();

        for (Id whoId : mapOfIdByActivityDate.keySet()) {
            SObjectType whoType = whoId.getSObjectType();
            System.debug('whoType' + whoType);
            System.debug('sobject' + Account.sObjectType);
            if (whoType == Lead.sObjectType) {
                setOfLeadIds.add(whoId);
            } else if (whoType == Account.sObjectType) {
                setOfAccountIds.add(whoId);
            }
        }
        System.debug('setOfAccountIds' + setOfAccountIds);
        if (!setOfLeadIds.isEmpty()) {
            listOfLeads = LeadSelector.getLeadActivityDate(setOfLeadIds);
            if (!listOfLeads.isEmpty()) {
                updateLeadActivityDate(listOfLeads, mapOfIdByActivityDate);
                update listOfLeads;
            }
        }
        if (!setOfAccountIds.isEmpty()) {
            listOfAccounts = AccountSelector.getAccountActivityDate(setOfAccountIds);
            System.debug('listOfAccounts' + listOfAccounts);
            if (!listOfAccounts.isEmpty()) {
                updateAccountActivityDate(listOfAccounts, mapOfIdByActivityDate);
                System.debug('listOfAccounts after' + listOfAccounts);
                update listOfAccounts;
            }
        }
    }

    private Map<Id, Date> getTaskWhoIdByActivityDate(List<Task> listOfNewTask) {
        Map<Id, Date> taskWhoIdByActivityDate = new Map<Id, Date>();

        for (Task task : listOfNewTask) {
            Boolean isWhoIdNotNull = task.WhoId != null;
            Boolean isAccountIdNotNull = task.AccountId != null;

            Boolean isActivityDateNotNull = task.ActivityDate != null;
            if (isActivityDateNotNull) {
                if (isWhoIdNotNull) {
                    taskWhoIdByActivityDate.put(task.WhoId, task.ActivityDate);
                } else if (isAccountIdNotNull) {
                    taskWhoIdByActivityDate.put(task.AccountId, task.ActivityDate);
                }
            }
        }

        return taskWhoIdByActivityDate;
    }

    private void updateLeadActivityDate(List<Lead> listOfLeads, Map<Id, Date> mapOfIdByActivityDate) {
        for (Lead lead : listOfLeads) {
            Date activityDateOfTask = mapOfIdByActivityDate.get(lead.Id);

            if (lead.Activity_Date__c == null) {
                lead.Activity_Date__c = activityDateOfTask;
            } else if (lead.Activity_Date__c < activityDateOfTask) {
                lead.Activity_Date__c = activityDateOfTask;
            }
        }
    }

    private void updateAccountActivityDate(List<Account> listOfAccounts, Map<Id, Date> mapOfIdByActivityDate) {
        for (Account account : listOfAccounts) {
            Date activityDateOfTask = mapOfIdByActivityDate.get(account.Id);

            if (account.Activity_Date__c == null) {
                account.Activity_Date__c = activityDateOfTask;
            } else if (account.Activity_Date__c < activityDateOfTask) {
                account.Activity_Date__c = activityDateOfTask;
            }
        }
    }

    private void updateActivityDateForLeadWhenTaskDeleted(List<Task> listOfOldTask) {
        Set<Id> setOfLeadIds = getRelatedLeadIds(listOfOldTask);

        if (!setOfLeadIds.isEmpty()) {
            Map<Id, Task> leadToLastTaskMap = getLeadIdToLastTask(setOfLeadIds);
            List<Lead> leadsToUpdate = getLeadsToUpdate(setOfLeadIds, leadToLastTaskMap);

            if (!leadsToUpdate.isEmpty()) {
                update leadsToUpdate;
            }
        }
    }

    private Set<Id> getRelatedLeadIds(List<Task> listOfOldTask) {
        Set<Id> setOfLeadIds = new Set<Id>();

        for (Task task : listOfOldTask) {
            if (task.WhoId != null && task.WhoId.getSObjectType() == Lead.sObjectType) {
                setOfLeadIds.add(task.WhoId);
            }
        }

        return setOfLeadIds;
    }

    private Map<Id, Task> getLeadIdToLastTask(Set<Id> setOfLeadIds) {
        Map<Id, Task> leadToLastTaskMap = new Map<Id, Task>();

        for (Task task : [SELECT WhoId, ActivityDate FROM Task WHERE WhoId IN :setOfLeadIds AND ActivityDate != null ORDER BY ActivityDate DESC]) {
            if (!leadToLastTaskMap.containsKey(task.WhoId)) {
                leadToLastTaskMap.put(task.WhoId, task);
            }
        }

        return leadToLastTaskMap;
    }

    private List<Lead> getLeadsToUpdate(Set<Id> setOfLeadIds, Map<Id, Task> leadToLastTaskMap) {
        List<Lead> leadsToUpdate = new List<Lead>();

        for (Id leadId : setOfLeadIds) {
            if (leadToLastTaskMap.containsKey(leadId)) {
                leadsToUpdate.add(new Lead(Id = leadId, Activity_Date__c = leadToLastTaskMap.get(leadId).ActivityDate));
            } else {
                leadsToUpdate.add(new Lead(Id = leadId, Activity_Date__c = null));
            }
        }

        return leadsToUpdate;
    }
}