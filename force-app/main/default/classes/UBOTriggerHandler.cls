public class UBOTriggerHandler {
    
    public void onAfterInsert(List<UBO__c> listOfUbo) {
        createRelatedDocuments(listOfUbo);
    }

    public void createRelatedDocuments(List<UBO__c> listOfUbo) {

        List<Document__c> listOfDocumentsForInsert = new List<Document__c>();

        for(UBO__c ubo : listOfUbo) {
            for(String document : ConstantUtility.SET_OF_INDIVIDUAL_DOCUMENTS) {
                Document__c recordOfDocument = new Document__c();
                recordOfDocument.Name = document;
                recordOfDocument.UBO__c = ubo.Id;
                recordOfDocument.Visibility_Type__c = 'Individual';
                listOfDocumentsForInsert.add(recordOfDocument);
            }
            for(String document : ConstantUtility.SET_OF_UBO_DOCUMENTS) {
                Document__c recordOfDocument = new Document__c();
                recordOfDocument.Name = document;
                recordOfDocument.UBO__c = ubo.Id;
                recordOfDocument.Visibility_Type__c = 'SOW/SOF';
                listOfDocumentsForInsert.add(recordOfDocument);
            }
        }

        insert listOfDocumentsForInsert;
    }
}