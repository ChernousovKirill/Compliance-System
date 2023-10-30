public without sharing class ApprovalPanelController {

    @AuraEnabled
    public static Customer__c getInfoFromCustomer(String recordId){

        return [SELECT Id, Name, Status__c, Is_Complete__c, Approver_Name__c, Unanswered_Comments__c,Onboarding_Officer__c FROM Customer__c WHERE Id = :recordId LIMIT 1];
        
    }

    @AuraEnabled
    public static Boolean checkIfUserIsSystemAdministrator(){
        
        String nameOfUserProfile = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
        
        if(nameOfUserProfile == ConstantUtility.SYSTEM_ADMINISTRATOR){
            return true;
        }else{
            return false;
        } 
    }

    @AuraEnabled
    public static Boolean checkIfUserHadPermissionForNewCustomer(){
        
        String nameOfUserProfile = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
        if(nameOfUserProfile == ConstantUtility.CHIEF_COMPLIANCE || nameOfUserProfile == ConstantUtility.HEAD_OF_MERCHANT || nameOfUserProfile == ConstantUtility.SYSTEM_ADMINISTRATOR){
            return true;
        }else{
            return false;
        } 
    }

    @AuraEnabled
    public static ApproverCommentWrapper getApproverComment(String recordId) {
        ApproverCommentWrapper wrapper = new ApproverCommentWrapper();
        
        List<Approver_Comment__c> listOfApproverComments = [
            SELECT Customer__c, Message__c, Status__c, Approver__r.Name
            FROM Approver_Comment__c
            WHERE Customer__c = :recordId AND Status__c = :ConstantUtility.SENT_STATUS
        ];
        
        wrapper.nameOfApprover = listOfApproverComments.isEmpty() ? null : listOfApproverComments[0].Approver__r.Name;
        wrapper.comments = listOfApproverComments.isEmpty() ? null : listOfApproverComments[0].Message__c;
        
        return wrapper;
    }

    public class ApproverCommentWrapper {
        @AuraEnabled
        public String nameOfApprover { get; set; }
        
        @AuraEnabled
        public String comments { get; set; }
    }
}