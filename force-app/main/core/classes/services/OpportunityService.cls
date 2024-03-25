public with sharing class OpportunityService {
    
    public static void updateProductStatusOnAccount (Map<Id, Map<String,String>> accountIdByChangedStage) {
        List<Account> listOfAccountsFotUpdate = new List<Account> ();

        for (Id idOfAccount : accountIdByChangedStage.keySet()) {
            Account account = new Account(Id = idOfAccount);
            Map<String, String> mapOfFieldsToUpdate = accountIdByChangedStage.get(idOfAccount);

            for (String fieldLabel : mapOfFieldsToUpdate.keySet()) {
                String fieldName = SobjectUtils.getFieldApiNameByLabel(ConstantUtility.ACCOUNT, fieldLabel);
                account.put(fieldName, mapOfFieldsToUpdate.get(fieldLabel));
            }

            listOfAccountsFotUpdate.add(account);
        }

        update listOfAccountsFotUpdate;
    }
}