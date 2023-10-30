public with sharing class AmlRiskScoreToolController {
    
    @AuraEnabled(cacheable=true)
    public static List<ApplicationFormService.SectionWrapper> getAmlRiskScoreSection() {
        List<ApplicationFormService.SectionWrapper> listOfSections = ApplicationFormService.getFormSectionWithoutTemplateVersion(ConstantUtility.CUSTOMER, ConstantUtility.AML_RISK_LEVEL);
        
        return listOfSections;
    }

    @AuraEnabled
    public static List<User> getAMLOfficersForAmlTool(String recordId){

        Set<Id> setOfUserIds = new Set<Id>();
        List<Customer__c> listOfCustomers = [SELECT Onboarding_Officer__c, Second_Onboarding_Officer__c FROM Customer__c WHERE Id = :recordId];
        
        for(Customer__c customer : listOfCustomers) {
            setOfUserIds.add(customer.Onboarding_Officer__c);
            setOfUserIds.add(customer.Second_Onboarding_Officer__c);
        }

        return [SELECT Id, Name FROM User WHERE Id  IN : setOfUserIds];

    }

    @AuraEnabled
    public static Map<String, Object> getValuesForAmlRiskTool(String recordId) {
        Map<String, Object> mapOfStringByObject = new Map<String, Object>();

            String fieldsForQuery = '';

            // Calculate field.score and totalScore
            List<ApplicationFormService.SectionWrapper> amlRiskScoreSections = getAmlRiskScoreSection();
            for(ApplicationFormService.SectionWrapper section : amlRiskScoreSections) {
                for (ApplicationFormService.FieldWrapper field : section.fields) {
                    fieldsForQuery += field.apiNameOfField + ', ';
                }
            }
            String query = 'SELECT AML_Officer__c, Date_of_AML__c, Reason_of_AML__c, AML_Tool_Comment__c, ' + fieldsForQuery.substring(0, fieldsForQuery.length() - 2) + ' FROM Customer__c WHERE Id = :recordId LIMIT 1'; 
            List<Customer__c> customers = Database.query(query);
            Customer__c customer = customers[0];
            mapOfStringByObject.put('customer', customer);

            Decimal totalScore = 0;
            for (ApplicationFormService.SectionWrapper section : amlRiskScoreSections) {
                for (ApplicationFormService.FieldWrapper field : section.fields) {
                    String apiNameOfField = field.apiNameOfField;
                    String defaultValue = String.valueOf(customer.get(apiNameOfField));
                    if (defaultValue == null) {
                        defaultValue = ConstantUtility.BLANK;
                    }
                    field.defaultValue = defaultValue;
                    for (ApplicationFormService.OptionWrapper option : field.options) {
                        if (String.valueOf(option.value) == defaultValue) {
                            field.score = option.score;
                            totalScore += option.score;
                            break;
                        }
                    }
                }
            }
            mapOfStringByObject.put('totalScore', totalScore);
            mapOfStringByObject.put('amlRiskScoreSections', amlRiskScoreSections); 

        return mapOfStringByObject;
    }

    @AuraEnabled
    public static void updateCustomerFromAmlTool(String recordId, Map<String, Object> fieldsForUpdate) {

        Customer__c customer = [SELECT Id FROM Customer__c WHERE Id = :recordId LIMIT 1];

        for (String fieldName : fieldsForUpdate.keySet()) {
            if(fieldName == ConstantUtility.DATE_OF_AML) {
                String fieldValue = (String) fieldsForUpdate.get(fieldName);
                Date dateValue = Date.valueOf(fieldValue);
                customer.put(fieldName, dateValue);
            } else {
                customer.put(fieldName, fieldsForUpdate.get(fieldName));
            }
        }

        update customer;

    }
}