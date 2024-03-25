public with sharing class AccountTriggerHandler extends TriggerHandler {
    private static final List<String> fieldsToCompare = new List<String>{
        'Pay_In__c', 'Pay_Out__c', 'Noda_Go__c', 'Noda_Buffet__c',
        'Payment_links__c', 'Trusted_Payments__c', 'Cards__c', 'KYW__c'
    };

    public override void afterInsert() {
        Set<Id> setOfIds = new Set<Id>();

        for (Account account : (List<Account>) Trigger.new) {
            setOfIds.add(account.Id);
        }

        if (!setOfIds.isEmpty()) {
            AccountService.createOpportunitiesForAccount(setOfIds);
        }
    }

    public override void beforeUpdate() {
        Map<Id, Account> oldMap = (Map<Id, Account>) Trigger.oldMap;
        Map<Id, Account> newMap = (Map<Id, Account>) Trigger.newMap;

        for (Account account : newMap.values()) {
            if (account.New_Comment__c != oldMap.get(account.Id).New_Comment__c && oldMap.get(account.Id).New_Comment__c != null) {
                account.Previous_comment__c = oldMap.get(account.Id).New_Comment__c;
            }
            if (account.OwnerId != oldMap.get(account.Id).OwnerId) {
                account.Previous_owner__c = oldMap.get(account.Id).OwnerId;
            }
        }

    }

    public override void afterUpdate() {
        Map<Id, Account> oldMap = (Map<Id, Account>) Trigger.oldMap;
        Map<Id, Account> newMap = (Map<Id, Account>) Trigger.newMap;
        Set<Id> setOfUpdatedAccountIds = new Set<Id>();
        Map<Account, List<String>> listOfAccountsWithFieldsToUpdate = new Map<Account, List<String>>();

        for (Account account : newMap.values()) {
            List<String> updatedFields = new List<String>();

            if (account.OwnerId != oldMap.get(account.Id).OwnerId) {
                setOfUpdatedAccountIds.add(account.Id);
            }
            for (String field : fieldsToCompare) {
                if (account.get(field) != oldMap.get(account.Id).get(field)) {
                    updatedFields.add(field);
                }
            }
            if (!updatedFields.isEmpty()) {
                listOfAccountsWithFieldsToUpdate.put(account, updatedFields);
            }
        }

        if (!setOfUpdatedAccountIds.isEmpty()) {
            setOfUpdatedAccountIds = AccountService.getAccountsWithFirstOwnerUpdate(setOfUpdatedAccountIds);

            if (!setOfUpdatedAccountIds.isEmpty()) {
                AccountService.changeOpportunitiesOwner(setOfUpdatedAccountIds);
            }
        }

        if (!listOfAccountsWithFieldsToUpdate.isEmpty()) {
            AccountService.updateOpportunities(listOfAccountsWithFieldsToUpdate);
        }
    }
}