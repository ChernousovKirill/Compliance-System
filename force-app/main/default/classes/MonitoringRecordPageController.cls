public class MonitoringRecordPageController {

    @AuraEnabled
    public static Monitoring__c getMonitoringById(String recordId){
        return [SELECT Id, Level__c, Reason__c, Monitoring_Status__c, User__c, Notes__c, Reason_Comment__c, Next_Monitoring_Date__c, Last_Monitoring_Date__c, Monitoring_Completed__c, Monitoring_Started_Date__c
                FROM Monitoring__c
                WHERE Id = :recordId
                LIMIT 1];  
    }

    @AuraEnabled
    public static List<ApplicationFormService.SectionWrapper> getMonitoringSections(String recordId) {
        List<ApplicationFormService.SectionWrapper> listOfMonitoringSection = new List<ApplicationFormService.SectionWrapper>();
        List<String> listOfSections = new List<String>();
        Map<String, Set<String>> mapOfMonitorinTypesBySection = getTypesOfMonitoringBySection();
        for (String section : mapOfMonitorinTypesBySection.keySet()) {
            listOfSections.add(section);
        }
        Map<String,List<ApplicationFormService.FieldWrapper>> mapOfFieldsBySection = getFieldsBySection(listOfSections, recordId);

        for (String section : mapOfMonitorinTypesBySection.keySet()) {
            ApplicationFormService.SectionWrapper monitoringSection = new ApplicationFormService.SectionWrapper();
            monitoringSection.label = section;
            monitoringSection.isMonitoringSection = section == 'Monitoring' ? true : false;
            monitoringSection.isPeriodKycSection = section == 'Periodic KYC Review' ? true : false;
            monitoringSection.fields = mapOfFieldsBySection.get(section);
            listOfMonitoringSection.add(monitoringSection);
        }
        return listOfMonitoringSection;
    }

    @AuraEnabled
    public static void updateMonitoringFields(String recordId, Map<String, Object> fieldsForUpdate) {
        Monitoring__c monitoring = [SELECT Id FROM Monitoring__c WHERE Id = :recordId LIMIT 1];

        for (String fieldName : fieldsForUpdate.keySet()) {
            String typeOfObject = CustomerDetailPageController.getFieldDataType('Monitoring__c', fieldName);

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
                    monitoring.put(fieldName, valueOfField);
                }
            }
        }

        update monitoring;
    }

    @AuraEnabled
    public static void updateMonitoringTypeValues(List<Map<Object, Object>> listOfRecordsToUpdate) {
    List<Monitoring_Type__c> listOfMonitoringTypesToUpdate = new List<SObject>();

    for (Map<Object, Object> record : listOfRecordsToUpdate) {
        Id recordId = (Id)record.get('recordId');
        List<Object> fieldsToUpdate = (List<Object>)record.get('fieldsToUpdate');

        Monitoring_Type__c monitoringTypeToUpdate = new Monitoring_Type__c();
        monitoringTypeToUpdate.Id = recordId;

        for (Object fieldUpdate : fieldsToUpdate) {
            Map<Object, Object> mapOfValueByFieldApiToUpdate = (Map<Object, Object>)fieldUpdate;
            String apiNameOfField = (String)mapOfValueByFieldApiToUpdate.get('fieldApi');
            String typeOfObject = CustomerDetailPageController.getFieldDataType('Monitoring_Type__c', apiNameOfField);

            if (typeOfObject == ConstantUtility.CURRENCY_TYPE || typeOfObject == ConstantUtility.NUMBER_TYPE || typeOfObject == ConstantUtility.DOUBLE_TYPE) {
                monitoringTypeToUpdate.put(apiNameOfField, Decimal.valueOf((String)mapOfValueByFieldApiToUpdate.get('updatedValue')));
            } else if (typeOfObject == ConstantUtility.DATE_TYPE) {
                monitoringTypeToUpdate.put(apiNameOfField, Date.valueOf((String)mapOfValueByFieldApiToUpdate.get('updatedValue')));
            } else {
                monitoringTypeToUpdate.put(apiNameOfField, mapOfValueByFieldApiToUpdate.get('updatedValue'));
            }
        }

        listOfMonitoringTypesToUpdate.add(monitoringTypeToUpdate);
    }
    System.debug('listOfMonitoringTypesToUpdate ' + listOfMonitoringTypesToUpdate);
    update listOfMonitoringTypesToUpdate;
}


    @AuraEnabled
    public static Map<String,List<ApplicationFormService.FieldWrapper>>  getFieldsBySection(List<String> listOfSections, String recordId){

        Map<String,List<ApplicationFormService.FieldWrapper>> mapOfFieldsBySection = new Map<String,List<ApplicationFormService.FieldWrapper>>();
        List<ApplicationFormService.FieldWrapper> listOfMonitoringSectionFields = new List<ApplicationFormService.FieldWrapper>();
        List<ApplicationFormService.FieldWrapper> listOfKYCReviewSectionFields = new List<ApplicationFormService.FieldWrapper>();
        
        List<Monitoring_Type__c> listOfMonitoringTypes = [SELECT  Id, Monitoring__c, Section__c, Type__c, Status__c, Comment__c, Next_Date__c, Notify_Before_days__c 
                                                          FROM Monitoring_Type__c
                                                          WHERE Section__c IN :listOfSections
                                                          AND Monitoring__c = : recordId];
        System.debug('listOfMonitoringTypes ' + listOfMonitoringTypes);

        for(Monitoring_Type__c monitoringType : listOfMonitoringTypes) {
            ApplicationFormService.FieldWrapper field = new ApplicationFormService.FieldWrapper();
        
            if(monitoringType.Section__c == 'Monitoring') {
                field.typeOfMonitoring = monitoringType.Type__c;
                field.idOfMonitoring = monitoringType.Id;
                field.monitoringNextDate = monitoringType.Next_Date__c;
                field.monitoringNotifyBefore = monitoringType.Notify_Before_days__c;
                listOfMonitoringSectionFields.add(field);
            } else if(monitoringType.Section__c == 'Periodic KYC Review') {
                field.typeOfMonitoring = monitoringType.Type__c;
                field.idOfMonitoring = monitoringType.Id;
                field.options = getOptionsForMonitoringStatus(monitoringType.Type__c);
                field.statusOfMonitoring = monitoringType.Status__c;
                field.commentOfMonitoring = monitoringType.Comment__c;
                listOfKYCReviewSectionFields.add(field);
            }
        }
        mapOfFieldsBySection.put('Monitoring', listOfMonitoringSectionFields);
        mapOfFieldsBySection.put('Periodic KYC Review', listOfKYCReviewSectionFields);
        
        return mapOfFieldsBySection;
    }

    public static List<ApplicationFormService.OptionWrapper> getOptionsForMonitoringStatus(String nameOfMonitoringType) {

        List<ApplicationFormService.OptionWrapper> listOfFieldOptions = new List<ApplicationFormService.OptionWrapper>();

        List<String> listOfBusinessModelOptions = new List<String> {
            'Has not been changed',
            'Has changed'
        };

        List<String> listOfMonthlyTurnoverOptions = new List<String> { 
            'Lower than declared',
            'As expected',
            'Monthly turnover is higher than   declared'
        };
        
        List<String> listOfWebsiteOptions = new List<String> { 
            'Has not been changed',
            'Added new'
        };
        
        List<String> listOfStatusOptions = new List<String> { 
            'Pending',
            'Verified',
            'Postponed',
            'Rejected',
            'Not Started'
        };

        if(nameOfMonitoringType == 'Business Model') {
            for(String option : listOfBusinessModelOptions) {
                ApplicationFormService.OptionWrapper optionWrapper = new ApplicationFormService.OptionWrapper();
                optionWrapper.label = option;
                optionWrapper.value = option;
                listOfFieldOptions.add(optionWrapper);
            }
        } else if (nameOfMonitoringType == 'Monthly Turnover volumes') {
            for(String option : listOfMonthlyTurnoverOptions) {
                ApplicationFormService.OptionWrapper optionWrapper = new ApplicationFormService.OptionWrapper();
                optionWrapper.label = option;
                optionWrapper.value = option;
                listOfFieldOptions.add(optionWrapper);
            }
        } else if (nameOfMonitoringType == 'Websites') {
            for(String option : listOfWebsiteOptions) {
                ApplicationFormService.OptionWrapper optionWrapper = new ApplicationFormService.OptionWrapper();
                optionWrapper.label = option;
                optionWrapper.value = option;
                listOfFieldOptions.add(optionWrapper);
            }
        } else {
            for(String option : listOfStatusOptions) {
                ApplicationFormService.OptionWrapper optionWrapper = new ApplicationFormService.OptionWrapper();
                optionWrapper.label = option;
                optionWrapper.value = option;
                listOfFieldOptions.add(optionWrapper);
            }
        }
        return listOfFieldOptions;
    }

    public static Map<String, Set<String>> getTypesOfMonitoringBySection() {

        Map<String, Set<String>> mapOfMonitorinTypesBySection = new Map<String, Set<String>>();
        List<ApplicationFormService.OptionWrapper> listOfSectionValues = ApplicationFormService.getOptionsForPicklist('Section__c', 'Monitoring_Type__c');
        for(ApplicationFormService.OptionWrapper section : listOfSectionValues) {
            if(section.label == 'Monitoring') {
                mapOfMonitorinTypesBySection.put(section.label, ConstantUtility.SET_OF_MONITORING_SECTION_TYPES);
            } else if(section.label == 'Periodic KYC Review') {
                mapOfMonitorinTypesBySection.put(section.label, ConstantUtility.SET_OF_KYC_REVIEW_SECTION_TYPES);
            }
        }

    return mapOfMonitorinTypesBySection;
    }
}