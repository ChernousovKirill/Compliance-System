public with sharing class AccountHistorySelector {
    public static List<SObject> getAccountHistory(Set<Id> setOfAccountIds) {
        return [
            SELECT AccountId
            FROM AccountHistory
            WHERE AccountId IN :setOfAccountIds
            AND Field = 'Owner'
            AND DataType = 'EntityId'
        ];
    }
}