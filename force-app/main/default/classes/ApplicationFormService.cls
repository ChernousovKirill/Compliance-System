public class ApplicationFormService {

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
                                                             Order__c, Read_Only__c, Type__c, Field_Notes__c, Has_notes__c, Reference_Object__c, Is_Hide__c
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

    public class SectionWrapper {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public Decimal order { get; set; }
        @AuraEnabled
        public Decimal numberOfColumns { get; set; }
        @AuraEnabled
        public Boolean readOnly { get; set; }
        @AuraEnabled
        public List<FieldWrapper> fields { get; set; }
        @AuraEnabled
        public String stringOfColumnsSize { get; set; }
        @AuraEnabled
        public Boolean amlAssessmentSection { get; set; }
        @AuraEnabled
        public Boolean bankAccountSection { get; set; }
        @AuraEnabled
        public Boolean lastMonthTransactionSection { get; set; }
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
        public Boolean areFieldsReference { get; set; }
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
        public List<OptionWrapper> options { get; set; }
    }

    public class OptionWrapper {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
        @AuraEnabled
        public Decimal score { get; set; }
    }

    public class AdditionalDocumentWrapper {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public Boolean value { get; set; }
    }

    public class TransactionsWrapper {
        @AuraEnabled
        public String month { get; set; }
        @AuraEnabled
        public String amount { get; set; }
    }
}