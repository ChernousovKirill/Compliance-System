public with sharing class EmailService {  

    public static void sendEmails(List<SObject> listOfRecords, String[] toAddresses, Id addressId, String subject) {
        List<Messaging.SingleEmailMessage> listOfSingleEmailMessages = buildEmailTemplate(listOfRecords, toAddresses, addressId, subject);

        List<Messaging.SendEmailResult> listOfSendEmailResults = Messaging.sendEmail(listOfSingleEmailMessages, false);
            for (Messaging.SendEmailResult sendEmailResultItem : listOfSendEmailResults) {

                if (!sendEmailResultItem.isSuccess()) {
                    LoggerUtil.error('Email did not send ' + sendEmailResultItem.getErrors().toString());
                }
            }
    }
    public static List<Messaging.SingleEmailMessage> buildEmailTemplate(List<SObject> listOfRecords, String[] toAddresses, Id addressId, String subject) {
        List<Messaging.SingleEmailMessage> listOfSingleEmailMessages = new List<Messaging.SingleEmailMessage>();
        String body;
        if(!listOfRecords.isEmpty()) {
            for(SObject record : listOfRecords) {
                SObjectType sobjectType = record.Id.getSObjectType();
                if (sobjectType == Lead.sObjectType) {  
                    toAddresses.add((String)record.get('Owner_Email__c'));
                    body = buildNewDigitalLeadBody(record);
                }
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(toAddresses);
                    mail.setSubject(subject);
                    mail.setOrgWideEmailAddressId(addressId);
                    mail.setHtmlBody(body);
                    listOfSingleEmailMessages.add(mail);
            }
        }            
            
        return listOfSingleEmailMessages;  
    }

    private static String buildNewDigitalLeadBody(SObject record) {
        Noda_Custom_Settings__c nodaCustomSettings = Noda_Custom_Settings__c.getOrgDefaults();

        String link = nodaCustomSettings.Org_URL__c + record.Id;

        String body = String.format(Label.newDigitalLeadEmail, new List<Object>{
            (String)record.get('LastName'), (String)record.get('FirstName'), (String)record.get('OwnerFullName__c'), link
        });
            
        return body;  
    }

}  
