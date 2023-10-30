public class DirectorTriggerHandler {

    public void onAfterInsert(List<Director__c> listOfDirectors) {
        createRelatedDocuments(listOfDirectors);
    }

    public void createRelatedDocuments(List<Director__c> listOfDirectors) {

        List<Document__c> listOfDocumentsForInsert = new List<Document__c>();

        for(Director__c director : listOfDirectors) {
            for(String document : ConstantUtility.SET_OF_INDIVIDUAL_DOCUMENTS) {
                Document__c recordOfDocument = new Document__c();
                recordOfDocument.Name = document;
                recordOfDocument.Director__c = director.Id;
                recordOfDocument.Visibility_Type__c = 'Individual';
                listOfDocumentsForInsert.add(recordOfDocument);
            }
            for(String document : ConstantUtility.SET_OF_CORPORATE_DIRECTOR_DOCUMENTS) {
                Document__c recordOfDocument = new Document__c();
                recordOfDocument.Name = document;
                recordOfDocument.Director__c = director.Id;
                recordOfDocument.Visibility_Type__c = 'Corporate';
                listOfDocumentsForInsert.add(recordOfDocument);
            }
        }

        insert listOfDocumentsForInsert;
    }
}