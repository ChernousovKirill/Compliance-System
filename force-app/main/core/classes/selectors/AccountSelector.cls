public inherited sharing class AccountSelector {
    public static List<Account> getAccounts(Set<Id> setOfAccountIds) {
        return [
            SELECT Id, Name, OwnerId
            FROM Account
            WHERE Id IN :setOfAccountIds
        ];
    }

    public static Account getAccount(Id accountId) {
        return [
            SELECT Id, Name, OwnerId
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];
    }

    public static List<Account> getAccountRows(String searchKey) {
        return [
            SELECT Id, Name, Industry, OwnerFullName__c, Website, Status__c, Activity_Date__c
            FROM Account
            WHERE Name LIKE :searchKey
            OR Website LIKE :searchKey
        ];
    }

    public static List<Account> getAccountActivityDate(Set<Id> setOfAccountIds) {
        return [
            SELECT Id, Activity_Date__c 
            FROM Account 
            WHERE Id IN :setOfAccountIds
        ];
    }
}