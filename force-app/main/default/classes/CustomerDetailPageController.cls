public class CustomerDetailPageController {

    
    public static List<ApplicationFormService.SectionWrapper> getDetailsPageSection() {
        List<ApplicationFormService.SectionWrapper> listOfSections = ApplicationFormService.getFormSectionWithoutTemplateVersion(ConstantUtility.CUSTOMER, ConstantUtility.DETAILS_PAGE);
        
        return listOfSections;
    }

    @AuraEnabled
    public static Map<String, Object> getValuesForDetailesPage(String recordId) {

        Map<String, Object> mapOfStringByObject = new Map<String, Object>();
        Boolean isAMLRiskAssessmentCheckboxHide = false;

        String fieldsForQuery = '';
        List<ApplicationFormService.SectionWrapper> detailsPageSections = getDetailsPageSection();
        for(ApplicationFormService.SectionWrapper section : detailsPageSections) {
            for (ApplicationFormService.FieldWrapper field : section.fields) {
                fieldsForQuery += field.apiNameOfField + ', ';
            }
        }
        String query = 'SELECT ' + fieldsForQuery.substring(0, fieldsForQuery.length() - 2) + ' FROM Customer__c WHERE Id = :recordId LIMIT 1'; 
        List<Customer__c> customers = Database.query(query);
        Customer__c recordOfCustomer = customers[0];
        mapOfStringByObject.put('recordOfCustomer', recordOfCustomer);
        System.debug('recordOfCustomer' + recordOfCustomer.Status__c);

        List<ApplicationFormService.AdditionalDocumentWrapper> listOfAdditionalAMLDocuments = getAdditionalAMLDocument(recordOfCustomer.Id);
        List<ApplicationFormService.TransactionsWrapper> listOfLastMonthsTransactions = getLastMonthsTransactions(recordOfCustomer.Id);

        Decimal totalScore = 0;
        for (ApplicationFormService.SectionWrapper section : detailsPageSections) {
            for (ApplicationFormService.FieldWrapper field : section.fields) {
                String apiNameOfField = field.apiNameOfField;
                if(field.type == ConstantUtility.CHECKBOX) {
                    Boolean valueOfCheckbox = Boolean.valueOf(recordOfCustomer.get(apiNameOfField));
                    field.valueOfCheckbox = valueOfCheckbox;
                } else {
                    String defaultValue = String.valueOf(recordOfCustomer.get(apiNameOfField));
                    if (defaultValue == null) {
                        defaultValue = '';
                    }
                    field.defaultValue = defaultValue;
                }
                field.areFieldsText = field.type == ConstantUtility.TEXT ? true : false;
                field.areFieldsPicklist = field.type == ConstantUtility.PICKLIST ? true : false;
                field.areFieldsCheckbox = field.type == ConstantUtility.CHECKBOX ? true : false;
                field.areFieldsTextarea = field.type == ConstantUtility.TEXTAREA ? true : false;
                field.areFieldsListBox = field.type == ConstantUtility.LISTBOX ? true : false;
                field.areFieldsCurrency = field.type == ConstantUtility.CURRENCY_TYPE ? true : false;
                field.areFieldsNumber = field.type == ConstantUtility.NUMBER_TYPE ? true : false;
                field.areFieldsDate = field.type == ConstantUtility.DATE_TYPE ? true : false;
                if(field.apiNameOfField == ConstantUtility.OTHER_INDUSTRY) {
                    field.isHide = recordOfCustomer.Business_Industry_Activity__c == ConstantUtility.OTHER ? false : true;
                }

            }
            if(section.label == ConstantUtility.AML_RISK_ASSESSMENT) {
                for(ApplicationFormService.FieldWrapper field : section.fields) {
                    if(ConstantUtility.AML_RISK_SECTION_FIELDS.contains(field.apiNameOfField)){
                        if(recordOfCustomer.CDD_Level__c == ConstantUtility.ENHANCED_CDD) {
                            isAMLRiskAssessmentCheckboxHide = false;
                        } else {
                            isAMLRiskAssessmentCheckboxHide = true;
                        }
                        field.isHide = isAMLRiskAssessmentCheckboxHide;
                    }
                }
                if(!listOfAdditionalAMLDocuments.isEmpty()) {
                    for(ApplicationFormService.AdditionalDocumentWrapper additionalDocument : listOfAdditionalAMLDocuments) {
                        ApplicationFormService.FieldWrapper field = new ApplicationFormService.FieldWrapper();
                        field.labelOfField = additionalDocument.label;
                        field.idOfAdditionalDocument = additionalDocument.id;
                        field.valueOfCheckbox = additionalDocument.value;
                        field.areFieldsCheckbox = true;
                        field.hasNotes = false;
                        field.isHide = isAMLRiskAssessmentCheckboxHide;
                        field.readOnly = false;
                        field.isAdditionalDocument = true;
                        field.order = section.fields.size() + 1;
                        section.fields.add(field);
                    }
                }            
            }
            if(section.label == ConstantUtility.LAST_MONTHS_TRANSACTIONS) {
                if(!listOfLastMonthsTransactions.isEmpty()) {
                    for(ApplicationFormService.TransactionsWrapper lastMonthTransaction : listOfLastMonthsTransactions) {
                        ApplicationFormService.FieldWrapper monthField = new ApplicationFormService.FieldWrapper();
                        monthField.labelOfField = ConstantUtility.MONTH;
                        monthField.defaultValue = lastMonthTransaction.month;
                        monthField.areFieldsPicklist = true;
                        monthField.hasNotes = false;
                        monthField.readOnly = true;
                        monthField.options = ApplicationFormService.getOptionsForPicklist(ConstantUtility.MONTH_FIELD, ConstantUtility.MONTH_TRANSACTION);
                        monthField.order = section.fields.size() + 1;
                        section.fields.add(monthField);
                        ApplicationFormService.FieldWrapper amountField = new ApplicationFormService.FieldWrapper();
                        amountField.labelOfField = ConstantUtility.AMOUNT;
                        amountField.defaultValue = lastMonthTransaction.amount;
                        amountField.areFieldsCurrency = true;
                        amountField.hasNotes = false;
                        amountField.readOnly = true;
                        amountField.order = section.fields.size() + 1;
                        section.fields.add(amountField);
                    }
                }            
            }
            section.amlAssessmentSection = section.label == ConstantUtility.AML_RISK_ASSESSMENT ? true : false;
            section.lastMonthTransactionSection = section.label == ConstantUtility.LAST_MONTHS_TRANSACTIONS ? true : false;
        }
        mapOfStringByObject.put('detailsPageSections', detailsPageSections);
        mapOfStringByObject.put('isAMLRiskAssessmentCheckboxHide', isAMLRiskAssessmentCheckboxHide); 

        return mapOfStringByObject;
    }

    @AuraEnabled
    public static List<ApplicationFormService.AdditionalDocumentWrapper> addDocumentToWrapper(String labelOfAddtionalDocument, Boolean valueOfAdditionDocument) {

        List<ApplicationFormService.AdditionalDocumentWrapper> listOfAdditionalDocuments = new List<ApplicationFormService.AdditionalDocumentWrapper>();

        ApplicationFormService.AdditionalDocumentWrapper additionalDocument = new ApplicationFormService.AdditionalDocumentWrapper();
        additionalDocument.label = labelOfAddtionalDocument;
        additionalDocument.value = valueOfAdditionDocument;

        listOfAdditionalDocuments.add(additionalDocument);

        return listOfAdditionalDocuments;
    }

    @AuraEnabled
    public static void updateAdditionalDocumentFromEditForm(String recordId, Map<String, Object> updatedAdditionalDocuments, Map<String, Object> insertedAdditionalDocuments){

        if(!updatedAdditionalDocuments.isEmpty()) {
            List<AML_Risk_Document__c> listOfAdditionalAMLDocuments = [SELECT Id, Label__c, Value__c, Customer__c FROM AML_Risk_Document__c WHERE Id IN : updatedAdditionalDocuments.keySet()];
            for (AML_Risk_Document__c document : listOfAdditionalAMLDocuments) {
                if (updatedAdditionalDocuments.get(document.Id) != null) {
                    document.Value__c = Boolean.valueOf(updatedAdditionalDocuments.get(document.Id));
                }

            }
            update listOfAdditionalAMLDocuments;
        }
        if (!insertedAdditionalDocuments.isEmpty()) {
            List<AML_Risk_Document__c> listOfDocumentsForInsert = new List<AML_Risk_Document__c>();
            for (String labelOfDocument : insertedAdditionalDocuments.keySet()) {
                    AML_Risk_Document__c newDocument = new AML_Risk_Document__c();
                    newDocument.Label__c = labelOfDocument;
                    newDocument.Value__c = Boolean.valueOf(insertedAdditionalDocuments.get(labelOfDocument));
                    newDocument.Customer__c = recordId;
                    listOfDocumentsForInsert.add(newDocument);
            }
            insert listOfDocumentsForInsert;
        }
    }

    @AuraEnabled
    public static void updateCustomerFromEditForm(String recordId, Map<String, Object> fieldsForUpdate) {
        Customer__c customer = [SELECT Id FROM Customer__c WHERE Id = :recordId LIMIT 1];

        for (String fieldName : fieldsForUpdate.keySet()) {
            String typeOfObject = getFieldDataType(ConstantUtility.CUSTOMER, fieldName);

            if (typeOfObject != null) {
                Object fieldValue = fieldsForUpdate.get(fieldName);
                Object valueOfField = '';

                if (typeOfObject == ConstantUtility.CURRENCY_TYPE || typeOfObject == ConstantUtility.NUMBER_TYPE || typeOfObject == ConstantUtility.DOUBLE_TYPE) {
                    valueOfField = Decimal.valueOf((String) fieldValue);
                } else if (typeOfObject == ConstantUtility.DATE_TYPE) {
                    valueOfField = Date.valueOf((String) fieldValue);
                } else if (typeOfObject == ConstantUtility.DATE_TIME_TYPE) {
                    valueOfField = Datetime.valueOf((String) fieldValue);
                } else {
                    valueOfField = fieldValue;
                }

                if (valueOfField != null) {
                    customer.put(fieldName, valueOfField);
                }
            }
        }

        update customer;
    }

    public static List<ApplicationFormService.AdditionalDocumentWrapper> getAdditionalAMLDocument(String idOfCustomer) {

        List<AML_Risk_Document__c> listOfAdditionalAMLDocuments = [SELECT Id, Label__c, Value__c, Customer__c FROM AML_Risk_Document__c WHERE Customer__c = :idOfCustomer];
        List<ApplicationFormService.AdditionalDocumentWrapper> listOfAdditionalDocumentsWrapper = new  List<ApplicationFormService.AdditionalDocumentWrapper>();
        for(AML_Risk_Document__c additionalDocumet : listOfAdditionalAMLDocuments) {
            ApplicationFormService.AdditionalDocumentWrapper additionalDocumetWrapper = new ApplicationFormService.AdditionalDocumentWrapper();
            additionalDocumetWrapper.label = additionalDocumet.Label__c;
            additionalDocumetWrapper.value = additionalDocumet.Value__c;
            additionalDocumetWrapper.id = additionalDocumet.Id;

            listOfAdditionalDocumentsWrapper.add(additionalDocumetWrapper);
        }

        return listOfAdditionalDocumentsWrapper;
    }

    public static List<ApplicationFormService.TransactionsWrapper> getLastMonthsTransactions(String idOfCustomer) {

        List<Month_Transaction__c> listOfLastMonthsTransactions = [SELECT Month__c, Amount__c, Customer__c FROM Month_Transaction__c WHERE Customer__c = :idOfCustomer];
        List<ApplicationFormService.TransactionsWrapper> listOfLastMonthsTransactionsWrapper = new  List<ApplicationFormService.TransactionsWrapper>();
        for(Month_Transaction__c monthTransaction : listOfLastMonthsTransactions) {
            ApplicationFormService.TransactionsWrapper lastMonthTransactionWrapper = new ApplicationFormService.TransactionsWrapper();
            lastMonthTransactionWrapper.month = monthTransaction.Month__c;
            lastMonthTransactionWrapper.amount =String.valueOf(monthTransaction.Amount__c);
            listOfLastMonthsTransactionsWrapper.add(lastMonthTransactionWrapper);
        }

        return listOfLastMonthsTransactionsWrapper;
    }

    public static String getFieldDataType(String nameOfObject, String nameOfField) {
        SObjectType typeOfObject = Schema.getGlobalDescribe().get(nameOfObject);
        if (typeOfObject != null) {
            SObjectField field = typeOfObject.getDescribe().fields.getMap().get(nameOfField);
            if (field != null) {
                return field.getDescribe().getType().name();
            }
        }
        return null;
    }
}