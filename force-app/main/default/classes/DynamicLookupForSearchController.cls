public with sharing class DynamicLookupForSearchController {
    @AuraEnabled
    public static List<ResultWrapper> fetchRecords(SearchWrapper inputWrapper, String recordId) {
        try {
            if(inputWrapper != null){
                if(inputWrapper.objectApiName == 'Customer__c') {
                    inputWrapper.firstFieldApiName = 'Legal_Name__c';
                    inputWrapper.secondFieldApiName = 'Type_of_Relationships__c';
                }
                if(inputWrapper.objectApiName == 'User') {
                    inputWrapper.firstFieldApiName = 'Role_Name__c';
                    inputWrapper.secondFieldApiName = 'Email';
                }
                String fieldsToQuery = 'SELECT Id, ';
                if(string.isNotBlank(inputWrapper.fieldApiName)){
                    fieldsToQuery = fieldsToQuery + inputWrapper.fieldApiName;
                }
                if(string.isNotBlank(inputWrapper.firstFieldApiName)){
                    fieldsToQuery = fieldsToQuery + ', ' + inputWrapper.firstFieldApiName;
                }
                if(string.isNotBlank(inputWrapper.secondFieldApiName)){
                    fieldsToQuery = fieldsToQuery + ', ' + inputWrapper.secondFieldApiName;
                }
                String query = fieldsToQuery + ' FROM '+ inputWrapper.objectApiName;
                String filterCriteria = inputWrapper.fieldApiName + ' LIKE ' + '\'' + String.escapeSingleQuotes(inputWrapper.searchString.trim()) + '%\' LIMIT 10';
                if(String.isNotBlank(inputWrapper.selectedRecordId)) {
                    query += ' WHERE Id = \''+ inputWrapper.selectedRecordId + '\'';
                }else if(String.isNotBlank(inputWrapper.parentFieldApiName) && String.isNotBlank(inputWrapper.parentRecordId)){
                    query += ' WHERE '+ inputWrapper.parentFieldApiName+ ' = \''+ inputWrapper.parentRecordId + '\'';
                    if(inputWrapper.objectApiName == 'Customer__c') {
                        query += ' AND Id <> :' + recordId;
                    }
                    query += ' AND ' + filterCriteria;
                } 
                else {
                    if(inputWrapper.objectApiName == 'Customer__c') {
                        query += ' WHERE Id <> \'' + recordId + '\' AND ' + filterCriteria;
                    } else {
                        query += ' WHERE '+ filterCriteria;
                    }
                }
                List<ResultWrapper> returnWrapperList = new List<ResultWrapper>();
                for(SObject record : Database.query(query)) {
                    ResultWrapper resultWrapper = new ResultWrapper();
                    resultWrapper.name = (String)record.get(inputWrapper.fieldApiName);
                    resultWrapper.firstField = (String)record.get(inputWrapper.firstFieldApiName);
                    resultWrapper.secondField = (String)record.get(inputWrapper.secondFieldApiName);
                    resultWrapper.idOfRecord = (String)record.get('id');
                    returnWrapperList.add(resultWrapper);
                }
                return returnWrapperList;
            }
            return null;
        } catch (Exception err) {
            throw new AuraHandledException(err.getMessage());
        }
    }

    public class ResultWrapper{
        @AuraEnabled public String name{get;set;}
        @AuraEnabled public String firstField{get; set;}
        @AuraEnabled public String secondField{get;set;}
        @AuraEnabled public String idOfRecord{get;set;}
    }

    public class SearchWrapper {
        @AuraEnabled public String objectApiName{get;set;}
        @AuraEnabled public String fieldApiName{get;set;}
        @AuraEnabled public String firstFieldApiName{get;set;}
        @AuraEnabled public String secondFieldApiName{get;set;}
        @AuraEnabled public String searchString{get;set;}
        @AuraEnabled public String selectedRecordId{get;set;}
        @AuraEnabled public String parentRecordId{get;set;}
        @AuraEnabled public String parentFieldApiName{get;set;}
    }
}