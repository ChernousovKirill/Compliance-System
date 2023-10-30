public class CorporateKycTriggerHandler {
    public void onAfterInsert(List<Corporate_KYC__c> listOfCorporateKYC) {
        createRelatedDocuments(listOfCorporateKYC);
    }

    public void createRelatedDocuments(List<Corporate_KYC__c> listOfCorporateKYC) {

        List<Document__c> listOfDocumentsForInsert = new List<Document__c>();

        for(Corporate_KYC__c corporateKYC : listOfCorporateKYC) {
            for(String document : ConstantUtility.SET_OF_CORPORATE_KYC_DOCUMENTS) {
                Document__c recordOfDocument = new Document__c();
                recordOfDocument.Name = document;
                recordOfDocument.Corporate_KYC__c = corporateKYC.Id;
                listOfDocumentsForInsert.add(recordOfDocument);
            }
        }

        insert listOfDocumentsForInsert;
    }
}