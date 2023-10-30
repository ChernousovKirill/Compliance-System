public class ApplicationFormService {

    @AuraEnabled
    public static Map<String, Object> getValuesForRecordDetailesPage(Id recordId, String typeOfForm) {

        String nameOfObject = '';
        String fieldsForQuery = '';
        String recordTypeOfCorporateKYC;
        List<ApplicationFormService.FieldWrapper> fieldsWithIndividualVisibilityType = new List<ApplicationFormService.FieldWrapper>();
        List<ApplicationFormService.FieldWrapper> fieldsWithCorporateVisibilityType = new List<ApplicationFormService.FieldWrapper>();
        List<ApplicationFormService.FieldWrapper> fieldsWithVisibilityTypes = new List<ApplicationFormService.FieldWrapper>();

        if(recordId != null) {
            nameOfObject = recordId.getSObjectType().getDescribe().getName();
        }

        List<ApplicationFormService.SectionWrapper> sections = getFormSectionWithoutTemplateVersion(nameOfObject, typeOfForm);
        List<ApplicationFormService.AdditionalDocumentWrapper> listOfIndividualDocuments = getDocuments(recordId, 'Individual');
        List<ApplicationFormService.AdditionalDocumentWrapper> listOfCorporateDocuments = getDocuments(recordId, 'Corporate');
        List<ApplicationFormService.AdditionalDocumentWrapper> listOfSowSofDocuments = getDocuments(recordId, 'SOW/SOF');
        List<ApplicationFormService.AdditionalDocumentWrapper> listOfDocuments = getDocuments(recordId, null);


        List<ApplicationFormService.SectionWrapper> sectionsForDisplay = new List<ApplicationFormService.SectionWrapper>();
        Map<String,List<ApplicationFormService.FieldWrapper>> mapOfFieldsBySectionWithType  = new Map<String,List<ApplicationFormService.FieldWrapper>>();
        if(nameOfObject == 'License__c') {
            mapOfFieldsBySectionWithType = getFieldsForSectionWithTypes(recordId, nameOfObject);
        }

        Map<String, Object> mapOfStringByObject = new Map<String, Object>();

        for(ApplicationFormService.SectionWrapper section : sections) {
            for (ApplicationFormService.FieldWrapper field : section.fields) {
                if(field.apiNameOfField != null) {
                    if(!fieldsForQuery.contains(field.apiNameOfField) && !field.apiNameOfField.equals('Name')) {
                        fieldsForQuery += field.apiNameOfField + ', ';
                    }
                }
            }
        }

        if(nameOfObject == 'Corporate_KYC__c') {
            fieldsForQuery += 'Record_Type__c, ';
        }
        if(nameOfObject == 'License__c' || nameOfObject == 'Director__c') {
            fieldsForQuery += 'Customer__c, ';
        }
        String query = 'SELECT Name, ' + fieldsForQuery.substring(0, fieldsForQuery.length() - 2) + ' FROM ' + nameOfObject +' WHERE Id = :recordId LIMIT 1'; 
        List<SObject> listOfRecords = Database.query(query);
        SObject record = listOfRecords[0];

        if(typeOfForm == 'Corporate KYC') {
            recordTypeOfCorporateKYC = String.valueOf(record.get('Record_Type__c'));
        }

        for(ApplicationFormService.SectionWrapper section : sections) {
            if(recordTypeOfCorporateKYC != null) {
                if(section.label == recordTypeOfCorporateKYC) {
                    sectionsForDisplay.add(section);
                }
            } else {
                sectionsForDisplay.add(section);
            }
        }

        for(ApplicationFormService.SectionWrapper section : sectionsForDisplay) {
            if(ConstantUtility.SET_OF_SECTION_WITH_LICENSE_MONITORING_TYPES.contains(section.label)) {
                section.licenseAndMonitoringTypeFields = mapOfFieldsBySectionWithType.get(section.label);
                section.isSectionWithLicenseTypes = true;
            } 
            section.isSowAndSofSection = section.label == 'SOW/SOF' ? true : false;
            section.isUboSection = section.label == 'UBO' ? true : false;
            section.isLicenseAndPermitsSection = section.label == 'License & Permits' ? true : false;
            if(section.label == 'Policies & Procedures') {
                section.status = String.valueOf(record.get('Policies_Procedures_Status__c'));
            } else if(section.label == 'Examples of KYC packs') {
                section.status = String.valueOf(record.get('Examples_of_KYC_Status__c'));
            }

                for (ApplicationFormService.FieldWrapper field : section.fields) {
                    if(field.apiNameOfField != null) {
                        String apiNameOfField = field.apiNameOfField;
                        if(field.type == ConstantUtility.CHECKBOX) {
                            Boolean valueOfCheckbox = Boolean.valueOf(record.get(apiNameOfField));
                            field.valueOfCheckbox = valueOfCheckbox;
                        } else {
                            String defaultValue = String.valueOf(record.get(apiNameOfField));
                            if (defaultValue == null) {
                                defaultValue = '';
                            }
                            field.defaultValue = defaultValue;
                        }
                    }
                    field.areFieldsText = field.type == ConstantUtility.TEXT ? true : false;
                    field.areFieldsPicklist = field.type == ConstantUtility.PICKLIST ? true : false;
                    field.areFieldsCheckbox = field.type == ConstantUtility.CHECKBOX ? true : false;
                    field.areFieldsTextarea = field.type == ConstantUtility.TEXTAREA ? true : false;
                    field.areFieldsListBox = field.type == ConstantUtility.LISTBOX ? true : false;
                    field.areFieldsCurrency = field.type == ConstantUtility.CURRENCY_TYPE ? true : false;
                    field.areFieldsNumber = field.type == ConstantUtility.NUMBER_TYPE ? true : false;
                    field.areFieldsDate = field.type == ConstantUtility.DATE_TYPE ? true : false;
                    if(nameOfObject == 'License__c' || nameOfObject == 'Director__c') {
                        field.idOfCustomer = String.valueOf(record.get('Customer__c'));
                    }
                    if(field.visibilityType != null) {
                        if(field.visibilityType == 'Individual') {
                            fieldsWithIndividualVisibilityType.add(field);
                        } else if(field.visibilityType == 'Corporate') {
                            fieldsWithCorporateVisibilityType.add(field);
                        }
                        fieldsWithVisibilityTypes.add(field);
                    }
                }

                for(ApplicationFormService.FieldWrapper fieldWithType : fieldsWithVisibilityTypes) {
                    Integer indexOfField = section.fields.indexOf(fieldWithType);
                    section.fields.remove(indexOfField);
                }
        }

        mapOfStringByObject.put('sections', sectionsForDisplay);
        if(fieldsWithIndividualVisibilityType != null) {
            mapOfStringByObject.put('fieldsWithIndividualVisibilityType', fieldsWithIndividualVisibilityType);
        }
        if(fieldsWithCorporateVisibilityType != null) {
            mapOfStringByObject.put('fieldsWithCorporateVisibilityType', fieldsWithCorporateVisibilityType);
        }
        if(listOfIndividualDocuments != null) {
            mapOfStringByObject.put('listOfIndividualDocuments', listOfIndividualDocuments);
        }
        if(listOfCorporateDocuments != null) {
            mapOfStringByObject.put('listOfCorporateDocuments', listOfCorporateDocuments);
        }
        if(listOfSowSofDocuments != null) {
            mapOfStringByObject.put('listOfSowSofDocuments', listOfSowSofDocuments);
        }
        if(listOfDocuments != null) {
            mapOfStringByObject.put('listOfDocuments', listOfDocuments);
        }

        return mapOfStringByObject;
    }

    @AuraEnabled
    public static void updateRecordFromDetailPage(String recordId, String apiNameOfObject, Map<String, Object> recordFieldsForUpdate, List<Map<Object, Object>> listOfUpdatedDocumentFields, List<Map<Object, Object>> listOfLicenseTypeRecordsToUpdate, List<AdditionalDocumentWrapper> listOfDocumentsForInsert) {
        if(!recordFieldsForUpdate.isEmpty()) {

            String query = 'SELECT Id FROM ' + apiNameOfObject + ' WHERE Id = :recordId LIMIT 1';
            List<SObject> listOfRecords = Database.query(query);
            SObject record = listOfRecords[0];

            for (String fieldName : recordFieldsForUpdate.keySet()) {
                String typeOfObject = CustomerDetailPageController.getFieldDataType(apiNameOfObject, fieldName);

                if (typeOfObject != null) {
                    Object fieldValue = recordFieldsForUpdate.get(fieldName);
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
                        record.put(fieldName, valueOfField);
                    }
                }
            }

            update record;
        }
        if(!listOfUpdatedDocumentFields.isEmpty()) {
            updateDocumentFromDetailPage(recordId, listOfUpdatedDocumentFields);
        }
        if(!listOfLicenseTypeRecordsToUpdate.isEmpty()) {
            updateLicenseTypeFromDetailPage(listOfLicenseTypeRecordsToUpdate);
        }
        if(!listOfDocumentsForInsert.isEmpty()) {
            insertAdditionalDocuments(recordId, apiNameOfObject , listOfDocumentsForInsert);
        }
    }

    public static void insertAdditionalDocuments(String recordId, String apiNameOfObject, List<AdditionalDocumentWrapper> listOfDocumentsForInsert) {

        List<Document__c> listOfDocumentForInsert = new List<Document__c>();
        for (AdditionalDocumentWrapper item : listOfDocumentsForInsert) {
            Document__c documentForInsert = new Document__c();
            documentForInsert.Name = item.label;
            documentForInsert.Status__c = item.status;
            documentForInsert.Visibility_Type__c = item.type;
            
            if (apiNameOfObject.equals('Corporate_KYC__c')) {
                documentForInsert.Corporate_KYC__c = recordId;
            } else if (apiNameOfObject.equals('License__c')) {
                documentForInsert.License__c = recordId;
            } else if (apiNameOfObject.equals('UBO__c')) {
                documentForInsert.UBO__c = recordId;
            } else if (apiNameOfObject.equals('Director__c')) {
                documentForInsert.Director__c = recordId;
            }
            
            listOfDocumentForInsert.add(documentForInsert);
        }
        insert listOfDocumentForInsert;
    }
    

    public static void updateLicenseTypeFromDetailPage(List<Map<Object, Object>> listOfLicenseTypeRecordsToUpdate) {
        
        List<License_Type__c> listOfLicenseTypesToUpdate = new List<SObject>();

            for (Map<Object, Object> record : listOfLicenseTypeRecordsToUpdate) {
                Id idOfLicenseType = (Id)record.get('idOfLicenseType');
                List<Object> fieldsToUpdate = (List<Object>)record.get('fieldsToUpdate');

                License_Type__c monitoringTypeToUpdate = new License_Type__c();
                monitoringTypeToUpdate.Id = idOfLicenseType;

                for (Object fieldUpdate : fieldsToUpdate) {
                    Map<Object, Object> mapOfValueByFieldApiToUpdate = (Map<Object, Object>)fieldUpdate;
                    String apiNameOfField = (String)mapOfValueByFieldApiToUpdate.get('fieldApi');
                    String typeOfObject = CustomerDetailPageController.getFieldDataType('License_Type__c', apiNameOfField);

                    if (typeOfObject == ConstantUtility.CURRENCY_TYPE || typeOfObject == ConstantUtility.NUMBER_TYPE || typeOfObject == ConstantUtility.DOUBLE_TYPE) {
                        monitoringTypeToUpdate.put(apiNameOfField, Decimal.valueOf((String)mapOfValueByFieldApiToUpdate.get('updatedValue')));
                    } else if (typeOfObject == ConstantUtility.DATE_TYPE) {
                        monitoringTypeToUpdate.put(apiNameOfField, Date.valueOf((String)mapOfValueByFieldApiToUpdate.get('updatedValue')));
                    } else {
                        monitoringTypeToUpdate.put(apiNameOfField, mapOfValueByFieldApiToUpdate.get('updatedValue'));
                    }
                }

                listOfLicenseTypesToUpdate.add(monitoringTypeToUpdate);
            }
            update listOfLicenseTypesToUpdate;
    
    }

    public static void updateDocumentFromDetailPage(String recordId, List<Map<Object, Object>> listOfUpdatedDocumentFields) {
        
        List<Document__c> listOfDocumentsToUpdate = new List<SObject>();

            for (Map<Object, Object> record : listOfUpdatedDocumentFields) {
                Id idOfRecord = (Id)record.get('recordId');
                List<Object> fieldsToUpdate = (List<Object>)record.get('fieldsToUpdate');

                Document__c documentToUpdate = new Document__c();
                documentToUpdate.Id = idOfRecord;

                for (Object fieldUpdate : fieldsToUpdate) {
                    Map<Object, Object> mapOfValueByFieldApiToUpdate = (Map<Object, Object>)fieldUpdate;
                    String apiNameOfField = (String)mapOfValueByFieldApiToUpdate.get('fieldApi');
                    documentToUpdate.put(apiNameOfField, mapOfValueByFieldApiToUpdate.get('updatedValue'));
                }

                listOfDocumentsToUpdate.add(documentToUpdate);
            }
            update listOfDocumentsToUpdate;
            updateContentVersionFromDetailPage(recordId, listOfDocumentsToUpdate);
    
    }

    public static void updateContentVersionFromDetailPage(String recordId, List<Document__c> listOfUpdatedDocument ) {

        Set<Id> setOfDocumentsId = new Set<Id>();
        List<String> listOfContentDocumentId = new List<String>();
        List<ContentVersion> listOfContentVersionForUpdate = new List<ContentVersion>();

        for(Document__c document : listOfUpdatedDocument) {
            setOfDocumentsId.add(document.Id);
        }

        List<Document__c> listOfDocuments = [SELECT Id, Name , Status__c, Comment__c, Document__c FROM Document__c WHERE Id IN :setOfDocumentsId];
        List<ContentDocumentLink> listOfContentDocumentLink = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        for(ContentDocumentLink documentLink : listOfContentDocumentLink) {
            listOfContentDocumentId.add(documentLink.ContentDocumentId);
        }
        List<ContentVersion> listOfContentVersion = FileUploadController.getAttachmentContentVersionRecordWithoutType(listOfContentDocumentId);

        for(ContentVersion contentVersion : listOfContentVersion) {
            for(Document__c document: listOfDocuments) {
                if((contentVersion.Type__c != 'Other' && contentVersion.Type__c == document.Name) || (contentVersion.Type__c == 'Other' && contentVersion.Other_Type__c == document.Name)) {
                    contentVersion.Status__c = document.Status__c;
                    contentVersion.Comment__c = document.Comment__c;
                    contentVersion.Document_Type__c = document.Document__c;
                    listOfContentVersionForUpdate.add(contentVersion);
                }
            }
        }
        update listOfContentVersionForUpdate;
    }

    public static List<SectionWrapper> getFormSectionWithoutTemplateVersion(String apiNameOfObject, String typeOfForm) {

        Set<Id> setOfFormSettingIds = new Set<Id>();
        Set<Id> setOfSectionsId = new Set<Id>();
        List<SectionWrapper> listOfSections = new List<SectionWrapper>();
        List<Form_Setting__c> listOfFormSettings = [SELECT Id, Form_Object_ApiName__c, Form_Type__c, Active__c
                                                    FROM Form_Setting__c 
                                                    WHERE Form_Object_ApiName__c = :apiNameOfObject 
                                                    AND Form_Type__c = :typeOfForm 
                                                    AND Active__c = TRUE];

        for(Form_Setting__c formSetting : listOfFormSettings) {
            setOfFormSettingIds.add(formSetting.Id);
        }                                          
        
        List<Form_Setting_Section__c> listOfFormSettingSections = [SELECT Id, Active__c, Form_Setting__c, Name, Key__c, Number_of_columns__c, Order__c, Read_Only__c
                                                    FROM Form_Setting_Section__c 
                                                    WHERE Form_Setting__c IN :setOfFormSettingIds
                                                    AND Active__c = TRUE
                                                    ORDER BY Order__c];

        for(Form_Setting_Section__c formSettingSection : listOfFormSettingSections) {
            setOfSectionsId.add(formSettingSection.Id);
        }

        Map<Id,List<FieldWrapper>> mapOfFieldsBySectionId = getFieldsFromSection(setOfSectionsId);

        for(Form_Setting_Section__c formSettingSection : listOfFormSettingSections) {
            SectionWrapper section = new SectionWrapper();
            section.label = formSettingSection.Name;
            section.order = formSettingSection.Order__c;
            section.numberOfColumns = formSettingSection.Number_of_columns__c;
            section.stringOfColumnsSize = 'slds-col slds-size_1-of-' + section.numberOfColumns + ' section-' + section.numberOfColumns;
            section.readOnly = formSettingSection.Read_Only__c;
            section.fields = mapOfFieldsBySectionId.get(formSettingSection.Id);
            listOfSections.add(section);
        }

        return listOfSections;

    }

    public static Map<Id,List<FieldWrapper>> getFieldsFromSection(Set<Id> setOfSectionsId) {

        List<Section_Field__c> listOfSectionFields = [SELECT Id, Active__c, Field_ApiName__c, Field_Label__c, Form_Setting_Section__c, Is_Required__c, Key__c, Object_ApiName__c,
                                                             Order__c, Read_Only__c, Type__c, Field_Notes__c, Has_notes__c, Reference_Object__c, Is_Hide__c, Visibility_Type__c, is_Used_Custom_Lookup__c
                                                      FROM Section_Field__c 
                                                      WHERE Active__c = TRUE 
                                                      AND Form_Setting_Section__c IN :setOfSectionsId
                                                      ORDER BY Order__c];
        Map<Id,List<FieldWrapper>> mapOfFieldsBySectionId = new Map<Id,List<FieldWrapper>>();
        Set<Id> setOfFieldIds = new Set<Id>();

        for(Section_Field__c sectionField : listOfSectionFields) {
            if(sectionField.Type__c == ConstantUtility.PICKLIST || sectionField.Type__c == ConstantUtility.LISTBOX) {
                setOfFieldIds.add(sectionField.Id);
            }
        }

        Map<Id,List<OptionWrapper>> mapOfFieldValuesByFieldId = getFieldValuesFromField(setOfFieldIds);
        
        for(Id idOfSection: setOfSectionsId) {
            List<FieldWrapper> listOfFields = new List<FieldWrapper>();
            for(Section_Field__c sectionField : listOfSectionFields) {
                if(idOfSection == sectionField.Form_Setting_Section__c) {
                    FieldWrapper field = new FieldWrapper();
                    field.apiNameOfField = sectionField.Field_ApiName__c;
                    field.apiNameOfReferenceObject = sectionField.Reference_Object__c;
                    field.labelOfField = sectionField.Field_Label__c;
                    field.order = sectionField.Order__c;
                    field.type = sectionField.Type__c;
                    field.readOnly = sectionField.Read_Only__c;
                    field.isHide = sectionField.Is_Hide__c;
                    field.hasNotes = sectionField.Has_notes__c;
                    field.notes = sectionField.Field_Notes__c;
                    field.linkOfIcon = getIconName(sectionField.Reference_Object__c);
                    field.options = mapOfFieldValuesByFieldId.get(sectionField.Id);
                    field.visibilityType = sectionField.Visibility_Type__c;
                    field.isUsedCustomLookup = sectionField.is_Used_Custom_Lookup__c;
                    listOfFields.add(field);
                }
            }
            mapOfFieldsBySectionId.put(idOfSection, listOfFields);
        }

        return mapOfFieldsBySectionId;

    }

    public static Map<Id,List<OptionWrapper>> getFieldValuesFromField(Set<Id> setOfFieldIds) {

        List<OptionWrapper> listOfIncorporationCountryScore = new List<OptionWrapper>();
        List<OptionWrapper> listOfUBOCitizenshipScore = new List<OptionWrapper>();
        List<OptionWrapper> listOfUBONationalityScore = new List<OptionWrapper>();
        List<OptionWrapper> listOfUBOResidenceScore = new List<OptionWrapper>();
        List<OptionWrapper> listOfCountriesPicklist = new List<OptionWrapper>();
        

        OptionWrapper blankValueOfCountry = new OptionWrapper();
        blankValueOfCountry.label = ConstantUtility.BLANK;
        blankValueOfCountry.score = 3;
        blankValueOfCountry.value = ConstantUtility.BLANK;

        List<Section_Field__c> listOfSectionFields = [SELECT Id, Active__c, Field_ApiName__c, Field_Label__c, Form_Setting_Section__c,Form_Setting_Section__r.Name, Is_Required__c, Key__c, Object_ApiName__c,
                                                             Order__c, Read_Only__c, Type__c, Sub_type__c
                                                      FROM Section_Field__c 
                                                      WHERE Active__c = TRUE 
                                                      AND Id IN :setOfFieldIds
                                                      ORDER BY Order__c];

        
        List<Field_Value__c> listOfFieldValues = [SELECT Id, Active__c, Section_Field__c, Label__c, Order__c, Score__c, Value__c
                                                  FROM Field_Value__c 
                                                  WHERE Active__c = TRUE 
                                                  AND Section_Field__c IN :setOfFieldIds
                                                  ORDER BY Order__c];

        List<Country__c> listOfCountries = [SELECT Name, Incorporation_Country_Score__c, UBO_Citizenship_Score__c, UBO_Nationality_Score__c, UBO_Residence_Score__c
                                            FROM Country__c
                                            ORDER BY Name];

        for(Country__c country : listOfCountries) {
            
            OptionWrapper incorporationCountryOption = new OptionWrapper();
            incorporationCountryOption.label = country.Name;
            incorporationCountryOption.score = country.Incorporation_Country_Score__c;
            incorporationCountryOption.value = country.Name;
            listOfIncorporationCountryScore.add(incorporationCountryOption);

            OptionWrapper UBOCitizenshipOption = new OptionWrapper();
            UBOCitizenshipOption.label = country.Name;
            UBOCitizenshipOption.score = country.UBO_Citizenship_Score__c;
            UBOCitizenshipOption.value = country.Name;
            listOfUBOCitizenshipScore.add(UBOCitizenshipOption);

            OptionWrapper UBONationalityOption = new OptionWrapper();
            UBONationalityOption.label = country.Name;
            UBONationalityOption.score = country.UBO_Nationality_Score__c;
            UBONationalityOption.value = country.Name;
            listOfUBONationalityScore.add(UBONationalityOption);

            OptionWrapper UBOResidenceOption = new OptionWrapper();
            UBOResidenceOption.label = country.Name;
            UBOResidenceOption.score = country.UBO_Residence_Score__c;
            UBOResidenceOption.value = country.Name;
            listOfUBOResidenceScore.add(UBOResidenceOption);

            OptionWrapper countryPicklist = new OptionWrapper();
            countryPicklist.label = country.Name;
            countryPicklist.value = country.Name;
            listOfCountriesPicklist.add(countryPicklist);

        }

        Map<Id,List<OptionWrapper>> mapOfFieldValuesByFieldId = new Map<Id,List<OptionWrapper>>();

        for(Section_Field__c sectionField : listOfSectionFields) {

            List<OptionWrapper> listOfOptions = new List<OptionWrapper>();
                
                if(sectionField.Type__c == ConstantUtility.LISTBOX) {
                    listOfOptions.addAll(getOptionsForPicklist(sectionField.Field_ApiName__c, ConstantUtility.CUSTOMER));
                } else if(sectionField.Sub_type__c == null) {
                    for(Field_Value__c valueOfField : listOfFieldValues) {
                        if(sectionField.Id == valueOfField.Section_Field__c) {
                            OptionWrapper option = new OptionWrapper();
                            option.label = valueOfField.Label__c;
                            option.score = valueOfField.Score__c;
                            option.value = valueOfField.Value__c;
                            listOfOptions.add(option);
                        }
                    }
                } else if(sectionField.Sub_type__c == ConstantUtility.COUNTRY) {
                    if(sectionField.Form_Setting_Section__r.Name == ConstantUtility.GEOGRAPHICAL_RISK) {
                        if(sectionField.Field_ApiName__c == ConstantUtility.COUNTRY_OF_INCORPORATION) {
                            listOfOptions.addAll(listOfIncorporationCountryScore);
                        } else if(sectionField.Field_ApiName__c == ConstantUtility.COUNTRY_OF_CITIZENSHIP) {
                            listOfOptions.addAll(listOfUBOCitizenshipScore);
                        } else if(sectionField.Field_ApiName__c == ConstantUtility.NATIONALITY_OF_UBO) {
                            listOfOptions.addAll(listOfUBONationalityScore);
                        } else if(sectionField.Field_ApiName__c == ConstantUtility.COUNTRY_OF_RESIDENCE) {
                            listOfOptions.addAll(listOfUBOResidenceScore);
                        }
                        listOfOptions.add(blankValueOfCountry);
                    } else {
                        listOfOptions.addAll(listOfCountriesPicklist);
                    }
                }
                mapOfFieldValuesByFieldId.put(sectionField.Id, listOfOptions);
            }
            return mapOfFieldValuesByFieldId;

    }

    public static Map<String, List<ApplicationFormService.FieldWrapper>> getFieldsForSectionWithTypes(String recordId, String nameOfInitialObject) {

        Map<String,List<ApplicationFormService.FieldWrapper>> mapOfFieldsBySection = new Map<String,List<ApplicationFormService.FieldWrapper>>();
        List<ApplicationFormService.FieldWrapper> listOfPoliciesAndProceduresSectionFields = new List<ApplicationFormService.FieldWrapper>();
        List<ApplicationFormService.FieldWrapper> listOfExampleKYCPackSectionFields = new List<ApplicationFormService.FieldWrapper>();

        String query = '';
        if(nameOfInitialObject != null) {
            if(nameOfInitialObject == 'License__c') {
                query = 'SELECT  Id, License__c, Section__c, Type__c, Status__c, Comment_Box__c FROM License_Type__c WHERE License__c = : recordId';
            }
        }

        List<SObject> listOfRecords = Database.query(query);
                                   
        for(SObject record : listOfRecords) {
            ApplicationFormService.FieldWrapper field = new ApplicationFormService.FieldWrapper();
            field.typeOfLicense = String.valueOf(record.get('Type__c'));
            field.idOfLicense = String.valueOf(record.get('Id'));
            field.statusOfLicense = String.valueOf(record.get('Status__c'));
            field.commentOfLicense = String.valueOf(record.get('Comment_Box__c'));
            if(String.valueOf(record.get('Type__c')).contains('Example')) {
                listOfExampleKYCPackSectionFields.add(field);
            } else {
                listOfPoliciesAndProceduresSectionFields.add(field);
            }
        }

        mapOfFieldsBySection.put('Examples of KYC packs',listOfExampleKYCPackSectionFields);
        mapOfFieldsBySection.put('Policies & Procedures',listOfPoliciesAndProceduresSectionFields);

        return mapOfFieldsBySection;
    }

    public static String getFieldLabel(String nameOfField) {
        Map<String, Schema.SObjectField> fieldMap = Customer__c.SObjectType.getDescribe().fields.getMap();
        Schema.SObjectField field = fieldMap.get(nameOfField);
        return field != null ? field.getDescribe().getLabel() : '';
    }

    @AuraEnabled(cacheable=true)
    public static List<OptionWrapper> getOptionsForPicklist(String apiNameOfField, String objectType) {
        List<OptionWrapper> options = new List<OptionWrapper>();

        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectType).getDescribe();
        Schema.DescribeFieldResult fieldResult = describeResult.fields.getMap().get(apiNameOfField).getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

    for (Schema.PicklistEntry entry : picklistValues) {
        OptionWrapper newOption = new OptionWrapper();
        newOption.label = entry.getLabel();
        newOption.value = entry.getValue();
        options.add(newOption);
    }

    return options;
    }

    public static String getIconName(String nameOfSObject){
        String nameOfIcon;
        List<Schema.DescribeTabSetResult> listOfTabsDescription = Schema.describeTabs();
        List<Schema.DescribeTabResult> listOfTabsDescriptionResult = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> listOfIcons = new List<Schema.DescribeIconResult>();

        for(Schema.DescribeTabSetResult tsr : listOfTabsDescription) { 
            listOfTabsDescriptionResult.addAll(tsr.getTabs()); 
        }

        for(Schema.DescribeTabResult tabDescriptionResult : listOfTabsDescriptionResult) {
            if( nameOfSObject == tabDescriptionResult.getSobjectName() ) {
                if( tabDescriptionResult.isCustom() == true ) {
                    listOfIcons.addAll(tabDescriptionResult.getIcons());
                } else {
                    nameOfIcon = 'standard:' + nameOfSObject.toLowerCase();
                }
            }
        }
        for (Schema.DescribeIconResult icon : listOfIcons) {
            if (icon.getContentType() == 'image/svg+xml'){
                nameOfIcon = 'custom:' + icon.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                break;
            }
        }
        return nameOfIcon;
    }

    public static List<ApplicationFormService.AdditionalDocumentWrapper> getDocuments(Id recordId, String typeOfDocument){

        String query = 'SELECT Id, Name, Document__c, Status__c, Comment__c, Visibility_Type__c FROM Document__c WHERE ';
        if(recordId != null) {
            String nameOfObject = recordId.getSObjectType().getDescribe().getName();
            query += nameOfObject + ' = :recordId';
        }
        if(typeOfDocument != null) {
            query += ' AND Visibility_Type__c = :typeOfDocument';
        }
        List<Document__c> listOfDocuments = Database.query(query);
        List<String> listOfContentDocumentId = new List<String>();
        String urlOfOrg = getUrlOfOrg();

        List<ContentDocumentLink> listOfContentDocumentLink = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        for(ContentDocumentLink documentLink : listOfContentDocumentLink) {
            listOfContentDocumentId.add(documentLink.ContentDocumentId);
        }
        List<ContentVersion> listOfContentVersion = FileUploadController.getAttachmentContentVersionRecordWithoutType(listOfContentDocumentId);

        List<ApplicationFormService.AdditionalDocumentWrapper> listOfRecordDocuments = new List<ApplicationFormService.AdditionalDocumentWrapper>();

        for(Document__c document : listOfDocuments) {
            ApplicationFormService.AdditionalDocumentWrapper documentOfRecord  = new ApplicationFormService.AdditionalDocumentWrapper();
            for(ContentVersion attachment : listOfContentVersion) {
                if(attachment.Type__c == document.Name && attachment.Active__c == true) {
                    documentOfRecord.isLink = true;
                    documentOfRecord.contentVersionLink = urlOfOrg + attachment.ContentDocumentId;
                } else if (attachment.Type__c == 'Other' && attachment.Other_Type__c == document.Name && attachment.Active__c == true) {
                    documentOfRecord.isLink = true;
                    documentOfRecord.contentVersionLink = urlOfOrg + attachment.ContentDocumentId;
                }
            }
            if(document.Name == 'Document of Trust') {
                documentOfRecord.isHide = true;
            }
            documentOfRecord.id = document.Id;
            documentOfRecord.label = document.Name;
            documentOfRecord.document = document.Document__c;
            documentOfRecord.status = document.Status__c;
            documentOfRecord.comment = document.Comment__c;
            listOfRecordDocuments.add(documentOfRecord);
        }

        return listOfRecordDocuments;
    }

    public static String getUrlOfOrg() {
        
        String urlOfOrg = '';
        Noda_Custom_Settings__c nodaCustomSettings = Noda_Custom_Settings__c.getOrgDefaults();

        if(nodaCustomSettings != null && nodaCustomSettings.Org_URL__c!=null) {
            urlOfOrg = nodaCustomSettings.Org_URL__c;
        }

        return urlOfOrg;
    }

    public class SectionWrapper {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String status { get; set; }
        @AuraEnabled
        public Decimal order { get; set; }
        @AuraEnabled
        public Decimal numberOfColumns { get; set; }
        @AuraEnabled
        public Boolean readOnly { get; set; }
        @AuraEnabled
        public List<FieldWrapper> fields { get; set; }
        @AuraEnabled
        public List<FieldWrapper> licenseAndMonitoringTypeFields { get; set; }
        @AuraEnabled
        public String stringOfColumnsSize { get; set; }
        @AuraEnabled
        public Boolean amlAssessmentSection { get; set; }
        @AuraEnabled
        public Boolean lastMonthTransactionSection { get; set; }
        @AuraEnabled
        public Boolean isMonitoringSection { get; set; }
        @AuraEnabled
        public Boolean isPeriodKycSection { get; set; }
        @AuraEnabled
        public Boolean isLicenseAndPermitsSection { get; set; }
        @AuraEnabled
        public Boolean isSectionWithLicenseTypes { get; set; }
        @AuraEnabled
        public Boolean isSowAndSofSection { get; set; }
        @AuraEnabled
        public Boolean isUboSection { get; set; }
        @AuraEnabled
        public List<FileUploadController.AttachmentFields> listOfAttachments { get; set; }
    }
    
    public class FieldWrapper {
        @AuraEnabled
        public String apiNameOfField { get; set; }
        @AuraEnabled
        public String apiNameOfReferenceObject { get; set; }
        @AuraEnabled
        public String labelOfField { get; set; }
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public String linkOfIcon { get; set; }
        @AuraEnabled
        public Boolean hasNotes { get; set; }
        @AuraEnabled
        public String notes { get; set; }
        @AuraEnabled
        public String defaultValue { get; set; }
        @AuraEnabled
        public String idOfAdditionalDocument { get; set; }
        @AuraEnabled
        public String visibilityType { get; set; }
        @AuraEnabled
        public Boolean valueOfCheckbox { get; set; }
        @AuraEnabled
        public Boolean readOnly { get; set; }
        @AuraEnabled
        public Boolean isHide { get; set; }
        @AuraEnabled
        public Boolean areFieldsText { get; set; }
        @AuraEnabled
        public Boolean areFieldsPicklist { get; set; }
        @AuraEnabled
        public Boolean areFieldsCheckbox { get; set; }
        @AuraEnabled
        public Boolean isUsedCustomLookup { get; set; }
        @AuraEnabled
        public Boolean areFieldsTextarea { get; set; }
        @AuraEnabled
        public Boolean areFieldsListBox { get; set; }
        @AuraEnabled
        public Boolean areFieldsCurrency { get; set; }
        @AuraEnabled
        public Boolean areFieldsNumber { get; set; }
        @AuraEnabled
        public Boolean areFieldsDate { get; set; }
        @AuraEnabled
        public Boolean isAdditionalDocument { get; set; }
        @AuraEnabled
        public Decimal score { get; set; }
        @AuraEnabled
        public Decimal order { get; set; }
        @AuraEnabled
        public String idOfMonitoring { get; set; }
        @AuraEnabled
        public String idOfLicense { get; set; }
        @AuraEnabled
        public String typeOfMonitoring { get; set; }
        @AuraEnabled
        public String typeOfLicense { get; set; }
        @AuraEnabled
        public String statusOfMonitoring { get; set; }
        @AuraEnabled
        public String statusOfLicense { get; set; }
        @AuraEnabled
        public String commentOfMonitoring { get; set; }
        @AuraEnabled
        public String commentOfLicense { get; set; }
        @AuraEnabled
        public String idOfCustomer { get; set; }
        @AuraEnabled
        public Date monitoringNextDate { get; set; }
        @AuraEnabled
        public Decimal monitoringNotifyBefore { get; set; }
        @AuraEnabled
        public List<OptionWrapper> options { get; set; }
    }

    public class OptionWrapper {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
        @AuraEnabled
        public Decimal score { get; set; }
        @AuraEnabled
        public Boolean selected { get; set; }
    }

    public class AdditionalDocumentWrapper {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String comment { get; set; }
        @AuraEnabled
        public String status { get; set; }
        @AuraEnabled
        public String document { get; set; }
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String contentVersionLink { get; set; }
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public Boolean value { get; set; }
        @AuraEnabled
        public Boolean isLink { get; set; }
        @AuraEnabled
        public Boolean isHide { get; set; }
    }

    public class TransactionsWrapper {
        @AuraEnabled
        public String month { get; set; }
        @AuraEnabled
        public String amount { get; set; }
    }
}