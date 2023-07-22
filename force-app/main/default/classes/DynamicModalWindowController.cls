public with sharing class DynamicModalWindowController {

    @AuraEnabled
    public static List<User> getApprovers(String recordId){

        List<User> listOfUser = new List<User>();
        Customer__c customer = [SELECT Id, AML_Risk_Level__c FROM Customer__c WHERE Id = :recordId LIMIT 1];
        String amlRiskLevel = customer.AML_Risk_Level__c;

        if(amlRiskLevel != null) {
            if(amlRiskLevel == ConstantUtility.HIGH_RISK) {
                listOfUser = [SELECT Id, Name, Profile.Name FROM User WHERE Profile.Name  = :ConstantUtility.CHIEF_COMPLIANCE];
            } else {
                listOfUser = [SELECT Id, Name, Profile.Name FROM User WHERE Profile.Name  = :ConstantUtility.CHIEF_COMPLIANCE OR Profile.Name = :ConstantUtility.HEAD_OF_MERCHANT];
            }
        }
        return listOfUser;
    }

    @AuraEnabled
    public static List<User> getAMLOfficersForOnboarding(){
        return [SELECT Id, Name, Profile.Name FROM User WHERE Profile.Name  = :ConstantUtility.AML_OFFICER];
    }

    @AuraEnabled
    public static Approver_Comment__c createCommentFromApprover(String recordId, String userId, String message){
        
        String idOfOnboardingOfficer;
        List<Customer__c> listOfCustomer = [SELECT Id, Status__c, Onboarding_Officer__c FROM Customer__c WHERE Id = :recordId];
        List<Customer__c> listOfCustomerForUpdate = new List<Customer__c>();

        for(Customer__c customer : listOfCustomer) {
            idOfOnboardingOfficer = customer.Onboarding_Officer__c;
            customer.Status__c = ConstantUtility.ONBOARDING_STATUS;
            listOfCustomerForUpdate.add(customer);
        }

        Approver_Comment__c approverCommentForInsert = new Approver_Comment__c(
                Customer__c = recordId,
                Approver__c = userId,
                Message__c = message,
                Onboarding_Officer__c = idOfOnboardingOfficer,
                Status__c = ConstantUtility.SENT_STATUS
        );
        insert approverCommentForInsert;
        update listOfCustomerForUpdate;
        return approverCommentForInsert;
    }

    @AuraEnabled
    public static List<Approver_Comment__c> updateApproverCommentWithAnswer(String recordId, String answer){
        
        String idOfOnboardingOfficer;
        List<Customer__c> listOfCustomer = [SELECT Id, Status__c FROM Customer__c WHERE Id = :recordId];
        List<Approver_Comment__c> listOfApproverComment = [ SELECT Id,Answer__c, Customer__c, Status__c FROM Approver_Comment__c WHERE Customer__c = :recordId];
        List<Customer__c> listOfCustomerForUpdate = new List<Customer__c>();
        List<Approver_Comment__c> listOfApproverCommentForUpdate = new List<Approver_Comment__c>();


        for(Customer__c customer : listOfCustomer) {
            customer.Status__c = ConstantUtility.SENT_TO_APPROVE_STATUS;
            listOfCustomerForUpdate.add(customer);
        }

        for(Approver_Comment__c approverComment : listOfApproverComment) {
            approverComment.Answer__c = answer;
            approverComment.Status__c = ConstantUtility.ANSWERED_STATUS;
            listOfApproverCommentForUpdate.add(approverComment);
        }
        update listOfApproverCommentForUpdate;
        update listOfCustomerForUpdate;
        return listOfApproverCommentForUpdate;
    }
}