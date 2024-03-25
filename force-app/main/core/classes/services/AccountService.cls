public with sharing class AccountService {
    public static OpportunityUtils oppUtilsCls {
        get {
            if (oppUtilsCls == null) {
                oppUtilsCls = new OpportunityUtils();
            }

            return oppUtilsCls;
        }
        set;
    }

    public static void createOpportunitiesForAccount(Set<Id> setOfCreatedAccounts) {
        List<Opportunity> listOfOpportunitiesToInsert = new List<Opportunity>();
        Noda_Custom_Settings__c settingsOfNoda = SettingUtils.settingsOfNoda;
        List<String> listOfUpsaleOpportunities = settingsOfNoda.Upsale_Opportunity__c.split(',');

        Map<String, Id> recordTypeNameToId = RecordTypeSelector.getRecordTypeNameToId(new List<String>{
            ConstantUtility.UPSALE
        });

        List<Account> listOfAccount = AccountSelector.getAccounts(setOfCreatedAccounts);

        for (Account account : listOfAccount) {
            listOfOpportunitiesToInsert.addAll(initOpportunityForProduct(listOfUpsaleOpportunities, account, ConstantUtility.NEGOTIATION, recordTypeNameToId.get(ConstantUtility.UPSALE)));
        }

        insert listOfOpportunitiesToInsert;
    }

    public static void changeOpportunitiesOwner(Set<Id> setOfUpdatedAccountIds) {
        List<Opportunity> listOfOpportunitiesToUpdate = new List<Opportunity>();

        List<Account> listOfAccounts = AccountSelector.getAccounts(setOfUpdatedAccountIds);
        List<Opportunity> listOfOpportunities = OpportunitySelector.getOpportunitiesByAcocunt(setOfUpdatedAccountIds);

        for(Account account : listOfAccounts) {
            for(Opportunity opportunity : listOfOpportunities) {
                if (account.Id == opportunity.AccountId) {
                    listOfOpportunitiesToUpdate.add(oppUtilsCls.updateOpportunityOwner(opportunity, account.OwnerId));
                }
            }
        }
        update listOfOpportunitiesToUpdate;
    }
    
    public static Set<Id> getAccountsWithFirstOwnerUpdate(Set<Id> setOfUpdatedAccountIds) {
        List<AccountHistory> listOfAccountHistory = AccountHistorySelector.getAccountHistory(setOfUpdatedAccountIds);

        for (AccountHistory accountHistory : listOfAccountHistory) {
            if (setOfUpdatedAccountIds.contains(accountHistory.AccountId)) {
                setOfUpdatedAccountIds.remove(accountHistory.AccountId);
            }
        }

        return setOfUpdatedAccountIds;
    }

    public static void updateOpportunities(Map<Account, List<String>> listOfAccountsWithFieldsToUpdate) {
        List<Opportunity> listOfOpportunitiesToUpdate = new List<Opportunity>();
        Map<String, SObjectField> serviceTypeFieldMap = new Map<String, SObjectField>{
            'Pay In' => Account.Pay_In__c,
            'Pay Out' => Account.Pay_Out__c,
            'Noda Go' => Account.Noda_Go__c,
            'Noda Buffet' => Account.Noda_Buffet__c,
            'Payment links' => Account.Payment_links__c,
            'Trusted Payments' => Account.Trusted_Payments__c,
            'Cards' => Account.Cards__c,
            'KYW' => Account.KYW__c
        };
    
        Set<Id> setOfAccountIds = new Set<Id>();
        for (Account account : listOfAccountsWithFieldsToUpdate.keySet()) {
            setOfAccountIds.add(account.Id);
        }
    
        Map<String, List<Opportunity>> serviceTypeOpportunitiesMap = new Map<String, List<Opportunity>>();
        for (String serviceType : serviceTypeFieldMap.keySet()) {
            serviceTypeOpportunitiesMap.put(serviceType, new List<Opportunity>());
        }
    
        for (Opportunity opportunity : [SELECT Id, Service_Type__c, StageName, AccountId FROM Opportunity WHERE AccountId IN :setOfAccountIds]) {
            String serviceType = opportunity.Service_Type__c;
            if (serviceTypeFieldMap.containsKey(serviceType)) {
                serviceTypeOpportunitiesMap.get(serviceType).add(opportunity);
            }
        }
    
        for (Account account : listOfAccountsWithFieldsToUpdate.keySet()) {
            List<String> updatedFields = listOfAccountsWithFieldsToUpdate.get(account);
            
            for (String updatedField : updatedFields) {
                String serviceType = getFieldServiceType(updatedField, serviceTypeFieldMap);
                SObjectField field = serviceTypeFieldMap.get(serviceType);
                List<Opportunity> opportunities = serviceTypeOpportunitiesMap.get(serviceType);
    
                for (Opportunity opportunity : opportunities) {
                    if (account.Id == opportunity.AccountId) {
                        opportunity.StageName = (String) account.get(field);
                        listOfOpportunitiesToUpdate.add(opportunity);
                    }
                }
            }
        }
        System.debug('listOfOpportunitiesToUpdate ' + listOfOpportunitiesToUpdate);
        update listOfOpportunitiesToUpdate;
    }

    private static String getFieldServiceType(String fieldName, Map<String, SObjectField> serviceTypeFieldMap) {
        for (String serviceType : serviceTypeFieldMap.keySet()) {
            if (serviceTypeFieldMap.get(serviceType).getDescribe().getName() == fieldName) {
                return serviceType;
            }
        }
        return null;
    }
    

    private static List<Opportunity> initOpportunityForProduct(List<String> typeOpportunities, Account account, String stage, Id recordTypeId) {
        List<Opportunity> opportunities = new List<Opportunity>();
        Date closeDate = Date.today().addMonths(1);

        for (String product : typeOpportunities) {
            String name = account.Name + ' - ' + product;
            opportunities.add(OpportunityUtils.createOpportunity(name, account.Id, account.OwnerId, stage, closeDate, recordTypeId, product));
        }

        return opportunities;
    }
}