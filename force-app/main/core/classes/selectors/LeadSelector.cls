public inherited sharing class LeadSelector {
    public static Decimal getLeadScore(Id leadId) {
        return [
            SELECT
                Score_Formula__c
            FROM Lead
            WHERE Id = :leadId
        ].Score_Formula__c;
    }

    public static List<Lead> getLeadByEmailAndWebsite(String email) {
        return [
            SELECT Score_Formula__c
            FROM Lead
            WHERE Email = :email AND Website != null
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
    }

    public static List<Lead> getLeadActivityDate(Set<Id> setOfLeadIds) {
        return [
            SELECT Id, Activity_Date__c 
            FROM Lead 
            WHERE Id IN :setOfLeadIds
        ];
    }

    public static List<Lead> getLeadRows(String searchKey) {
        return [
            SELECT Id, Name, Industry, Company, OwnerFullName__c, Website, Status, LeadSource, Activity_Date__c
            FROM Lead
            WHERE Name LIKE :searchKey
            OR Website LIKE :searchKey
            OR Company LIKE :searchKey
        ];
    }
}