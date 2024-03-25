public with sharing class OpportunitySelector {
    public static List<Opportunity> getOpportunitiesByAcocunt(Set<Id> setOfAccountIds) {
        return [
            SELECT Id, OwnerId, AccountId
            FROM Opportunity
            WHERE AccountId = :setOfAccountIds
        ];
    }
}