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

            Customer__c customer = [SELECT Are_there_any_relevant_Adverse_Media__c, Country_of_citizenship_of_UBO__c, Country_of_incorporation_of_the_Corpora__c, Country_of_residence_of_UBO__c,
                                           Does_customer_hold_license__c, Duration_of_business_relationships__c, How_merchant_was_introduced_to_Noda__c, How_settlement_will_be_made__c, Is_Source_of_Wealth_Source_of_Funds_know__c,
                                           Is_there_PEP_Involvment__c, Nationality_of_UBO__c, The_main_market_where_customer_operating__c, What_age_of_client_business__c, What_is_Monthly_Turnover_EUR__c,
                                           What_is_the_Corporate_structure__c, What_is_the_Delivery_Channel__c, What_is_the_industry_risk__c, What_Services_will_be_provided__c, Reason_of_AML__c, AML_Risk_Level__c, Date_of_AML__c, AML_Officer__c
                                    FROM Customer__c 
                                    WHERE Id = :recordId 
                                    LIMIT 1];

            mapOfStringByObject.put('customer', customer);

            // Calculate field.score and totalScore
            List<ApplicationFormService.SectionWrapper> amlRiskScoreSections = getAmlRiskScoreSection();
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