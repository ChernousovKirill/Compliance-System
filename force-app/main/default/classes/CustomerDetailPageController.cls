public class CustomerDetailPageController {

    
    public static List<ApplicationFormService.SectionWrapper> getDetailsPageSection() {
        List<ApplicationFormService.SectionWrapper> listOfSections = ApplicationFormService.getFormSectionWithoutTemplateVersion(ConstantUtility.CUSTOMER, ConstantUtility.DETAILS_PAGE);
        
        return listOfSections;
    }

    @AuraEnabled
    public static Map<String, Object> getValuesForDetailesPage(String recordId) {

        Map<String, Object> mapOfStringByObject = new Map<String, Object>();
        Boolean isAMLRiskAssessmentCheckboxHide = false;

        Customer__c recordOfCustomer = [SELECT AML_Risk_Level__c, AML_Risk_Matrix_ver__c, Score__c, CDD_Level__c, SOW_SOF__c, Enhanced_Periodic_KYC__c, Compliance_policies__c,
                                               Enhanced_Webshield__c, License__c, Enhnaced_Sanction_Screening__c, MLRO_Approval__c, Certified_Documents__c, Enhanced_TM__c, Certified_Organizational_Chart__c,
                                               Open_Banking_PayIns__c, Full_Reliance_WL__c, Open_Banking_PayIns_PayOuts__c, Partial_Reliance_WL__c, Acquiring_Card_Processing__c, Reseller__c, Direct_Merchant__c,
                                               Beneficiary_Name__c, IBAN__c, Bank_Name__c, Country_Bank__c, Bank_Currency__c, Bank_Status__c, Valid_Bank__c, Overall_Concerns_Comment_Box__c, Country_Blocks__c, From_Partner__c,
                                               Type_of_Relationships__c, Exp_Monthly_Volumes__c, DBA_Trade_Name__c, Legal_Name__c, Actual_Last_Months_Volumes__c, Legal_Form__c, Business_Industry_Activity__c, Registration_Number__c,
                                               Detailed_Description__c, VAT_Tax_ID_Number__c, Registered_Address__c, Country_of_Incorporation__c, Date_of_Incorporation__c, Sales_Agent__c, Account_Manager__c, Status__c,
                                               Rejected_Termination_Reason__c, Comment_Box__c, Business_Location__c, Risk_Comment_Box__c, Monthly_Turnover__c, MAX_TRX_CNT__c, AVG_TRX_CNT__c, MAX_TRX_AMT__c, MAX_Single_TRX_CNT__c,
                                               AVG_TRX_AMT__c, MAX_Single_TRX_AMT__c, Review_Started__c,Review_Completed__c, Onboarding_Officer__c, Approved_by__c, Second_Onboarding_Officer__c, Name_Surname__c, Approved_Rejected_Date__c,
                                               Other_Business_Industry_Activity__c
                                        FROM Customer__c 
                                        WHERE Id = :recordId 
                                        LIMIT 1];

        List<ApplicationFormService.AdditionalDocumentWrapper> listOfAdditionalAMLDocuments = getAdditionalAMLDocument(recordOfCustomer.Id);
        List<ApplicationFormService.TransactionsWrapper> listOfLastMonthsTransactions = getLastMonthsTransactions(recordOfCustomer.Id);


        mapOfStringByObject.put('recordOfCustomer', recordOfCustomer);

        List<ApplicationFormService.SectionWrapper> detailsPageSections = getDetailsPageSection();
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
                field.areFieldsReference = field.type == ConstantUtility.REFERENCE ? true : false;
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
            section.bankAccountSection = section.label == ConstantUtility.BANK_ACCOUNTS ? true : false;
            section.lastMonthTransactionSection = section.label == ConstantUtility.LAST_MONTHS_TRANSACTIONS ? true : false;
            if(section.bankAccountSection == true) {
                section.listOfAttachments = FileUploadController.getUploadedAttachments(recordId, section.label);
            }
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
                } else if (typeOfObject == ConstantUtility.MULTIPICKLIST) {
                    List<Object> fieldValues = (List<Object>) fieldValue;
                    for(Object value : fieldValues) {
                        valueOfField += value + ';' ;
                    }
                    String.valueOf(valueOfField).removeEnd(';');
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