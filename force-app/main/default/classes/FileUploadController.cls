public class FileUploadController {
   
    @AuraEnabled
    public static List<AttachmentFields> getUploadedAttachments(String recordId, String typeOfAttachment) {

        List<ContentDocumentLink> listOfContentDocumentLink = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        List<AttachmentFields> listOfUploadedAttachmentsWrapper = new List<AttachmentFields>();
        List<String> listOfContentDocumentId = new List<String>();

        for(ContentDocumentLink contentDocumentLink : listOfContentDocumentLink) {
            listOfContentDocumentId.add(contentDocumentLink.ContentDocumentId);
        }

        List<ContentVersion> listOfContentVersion = getAttachmentContentVersionRecord(listOfContentDocumentId, typeOfAttachment);

        for(ContentVersion contentVersion : listOfContentVersion) {
            AttachmentFields attachment = new AttachmentFields();
            attachment = fillAttachmentWrapper(contentVersion);
            listOfUploadedAttachmentsWrapper.add(attachment);
        }

        return listOfUploadedAttachmentsWrapper;
    }

    @AuraEnabled
    public static List<AttachmentFields> handleUploadNewAttachment(List<String> listOfAttachmentIds, String recordId, String typeOfAttachment) {

        List<ContentVersion> listOfAttachments = getAttachmentContentVersionRecordWithoutType(listOfAttachmentIds);

        List<AttachmentFields> listOfAttachmentsFields = new List<AttachmentFields>();
        Set<Id> contentDocumentIdForDelete = new Set<Id>();

        if (String.isNotBlank(recordId)) {
            
            for (ContentVersion document : listOfAttachments) {
                    document.Type__c = typeOfAttachment;
                    AttachmentFields attachment = fillAttachmentWrapper(document);
                    listOfAttachmentsFields.add(attachment);
            }

        } else {
            for(ContentVersion document : listOfAttachments){
                    AttachmentFields attachment = fillAttachmentWrapper(document);
                    listOfAttachmentsFields.add(attachment);
            }
        }
        if(listOfAttachmentsFields.size() > 0){
            List<ContentVersion> listOfAttachmentsForUpdate = new List<ContentVersion>();
            for(AttachmentFields attachment : listOfAttachmentsFields){
                listOfAttachmentsForUpdate.add(new ContentVersion(Id = attachment.id, Type__c = attachment.type));
            }
            update listOfAttachmentsForUpdate;
        }

        return listOfAttachmentsFields;
    }

    @AuraEnabled
    public static void deleteAttachment(String idOfContentDocument){
		delete [SELECT id FROM ContentDocument WHERE id = :idOfContentDocument];
    }

    public static List<ContentVersion> getAttachmentContentVersionRecord(List<String> listOfContentDocumentId, String typeOfAttachment){
        return [
                SELECT Id, ContentDocumentId, ContentSize, CreatedDate, FileType, Title, FileExtension, CreatedById, Type__c, Status__c
                FROM ContentVersion 
                WHERE ContentDocumentId IN :listOfContentDocumentId 
                AND Type__c = :typeOfAttachment
                ORDER BY CreatedDate
        ];
    }

    public static List<ContentVersion> getAttachmentContentVersionRecordWithoutType(List<String> listOfContentDocumentId){
        return [
                SELECT Id, ContentDocumentId, ContentSize, CreatedDate, FileType, Title, FileExtension, CreatedById, Type__c, Status__c
                FROM ContentVersion 
                WHERE ContentDocumentId IN :listOfContentDocumentId 
                ORDER BY CreatedDate
        ];
    }

    @AuraEnabled
    public static AttachmentFields fillAttachmentWrapper(ContentVersion document) {
        System.debug('type ' +  document.Status__c);
        AttachmentFields attachment = new AttachmentFields();
        attachment.id = document.id;
        attachment.title = document.title;
        attachment.fileType = document.fileType;
        attachment.type = document.Type__c;
        attachment.fileExtension = document.fileExtension;
        attachment.iconName = getFileIcon(document.fileExtension);
        attachment.contentDocumentId = document.ContentDocumentId;
        attachment.contentSize = getFileSize(document.contentSize);
        attachment.createdDate = String.valueOf(document.CreatedDate.format()).replace(',', '');
        attachment.createdById = document.createdById;
        attachment.statusOfAttachment = document.Status__c;
        attachment.isCanBeRemoved = false;
        return attachment;
    }

    /**
     * @description
     * return the string value of the file extension.
     * @param fileExtension - input file extension.
     * @return the string value of the file extension or unknown format in negative case.
    */
    private static String getFileIcon(String fileExtension){
        if (ConstantUtility.SET_OF_EXISTING_ICONS.contains(fileExtension)) {
            return String.valueOf('doctype:' + fileExtension);
        } else {
            return ConstantUtility.DOCTYPE_UNKNOWN;
        }
    }
    /**
     * @description
     * return the document size based on input documentSize.
     * @param documentSize - decimal value of document.
     * @return the document size in Bytes/KB/MB depends on the size.
    */
    private static String getFileSize(Decimal documentSize){
        if (documentSize < 1024){
            return string.valueOf(documentSize) + ' Bytes';
        } else if (documentSize >= 1024 && documentSize < (1024 * 1024)){
            return string.valueOf(documentSize.divide(1024,2)) + ' KB';
        } else {
            return string.valueOf(documentSize.divide((1024 * 1024),2)) + ' MB';
        }
    }

    @AuraEnabled
    public static String getDocumentIdFromContentVersion(String contentVersionId) {
        System.debug('contentVersionId ' + contentVersionId);
        return getContentVersionById(contentVersionId).ContentDocumentId;
    }

    @AuraEnabled
    public static ContentVersion getContentVersionById(String contentVersionId) {
        return [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1];
    }

    public class AttachmentFields {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String contentDocumentId {get;set;}
        @AuraEnabled
        public String createdById {get;set;}
        @AuraEnabled
        public String contentSize {get;set;}
        @AuraEnabled
        public String fileType {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public String createdDate {get;set;}
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public String fileExtension {get;set;}
        @AuraEnabled
        public String iconName {get;set;}
        @AuraEnabled
        public String statusOfAttachment {get;set;}
        @AuraEnabled
        public Boolean isCanBeRemoved {get;set;}
    }

}