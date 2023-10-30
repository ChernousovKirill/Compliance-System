public class DynamicModalWindowController {

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
    public static List<User> getComplianceTeamMembers(String recordId){

        return [SELECT Id, Name, Profile.Name FROM User WHERE Profile.Name  = :ConstantUtility.CHIEF_COMPLIANCE OR Profile.Name = :ConstantUtility.HEAD_OF_MERCHANT OR Profile.Name = :ConstantUtility.AML_OFFICER];

    }

    @AuraEnabled
    public static List<Website__c> getWebsites(String recordId){

        String idOfCustomer = [SELECT Id, Customer__c FROM Website__c WHERE Id = :recordId LIMIT 1].Customer__c;
        return [SELECT Id, Name FROM Website__c WHERE Customer__c = :idOfCustomer AND Id != :recordId];

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

    @AuraEnabled
    public static Website__c copyWebsiteData(String recordId, String idOfWebsite){

        Website__c initialWebsite = [SELECT Age_Restriction__c, AML_policy__c, Category__c, Comply_Advantage_Screening__c, Contact_Us_email__c, Contact_Us_phone__c, Currency__c, Date__c,
                                        Domain_Ownership_in_WhoIs__c, Free_Trial_period__c, Industry__c, Legal_Name__c, License__c, Privacy_Policy__c, Refund_Policy__c, Registered_Address__c,
                                        Status__c, Subscriptions_Membership__c, T_C__c,  Test_Account_Password__c, Test_Account_Username__c, Website_Included_in_the_License__c, Website_Overall__c
                                FROM Website__c
                                WHERE Id = :idOfWebsite
                                LIMIT 1];

        Website__c websiteForUpdate = new Website__c();
        websiteForUpdate.Id = recordId;
        websiteForUpdate.Age_Restriction__c = initialWebsite.Age_Restriction__c;
        websiteForUpdate.AML_policy__c = initialWebsite.AML_policy__c;
        websiteForUpdate.Category__c = initialWebsite.Category__c;
        websiteForUpdate.Comply_Advantage_Screening__c = initialWebsite.Comply_Advantage_Screening__c;
        websiteForUpdate.Contact_Us_email__c = initialWebsite.Contact_Us_email__c;
        websiteForUpdate.Contact_Us_phone__c = initialWebsite.Contact_Us_phone__c;
        websiteForUpdate.Currency__c = initialWebsite.Currency__c;
        websiteForUpdate.Date__c = initialWebsite.Date__c;
        websiteForUpdate.Domain_Ownership_in_WhoIs__c = initialWebsite.Domain_Ownership_in_WhoIs__c;
        websiteForUpdate.Free_Trial_period__c = initialWebsite.Free_Trial_period__c;
        websiteForUpdate.Industry__c = initialWebsite.Industry__c;
        websiteForUpdate.Legal_Name__c = initialWebsite.Legal_Name__c;
        websiteForUpdate.License__c = initialWebsite.License__c;
        websiteForUpdate.Privacy_Policy__c = initialWebsite.Privacy_Policy__c;
        websiteForUpdate.Refund_Policy__c = initialWebsite.Refund_Policy__c;
        websiteForUpdate.Registered_Address__c = initialWebsite.Registered_Address__c;
        websiteForUpdate.Status__c = initialWebsite.Status__c;
        websiteForUpdate.Subscriptions_Membership__c = initialWebsite.Subscriptions_Membership__c;
        websiteForUpdate.T_C__c = initialWebsite.T_C__c;
        websiteForUpdate.Test_Account_Password__c = initialWebsite.Test_Account_Password__c;
        websiteForUpdate.Test_Account_Username__c = initialWebsite.Test_Account_Username__c;
        websiteForUpdate.Website_Included_in_the_License__c = initialWebsite.Website_Included_in_the_License__c;
        websiteForUpdate.Website_Overall__c = initialWebsite.Website_Overall__c;

        update websiteForUpdate;
        return websiteForUpdate;

    }
}