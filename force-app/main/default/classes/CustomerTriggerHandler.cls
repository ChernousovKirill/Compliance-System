public class CustomerTriggerHandler {

    public void onBeforeUpdate(Map<Id,Customer__c> oldMap, Map<Id,Customer__c> newMap) {

        Set<Id> setOfApprovedOrRejectedId = new Set<Id>();

        for(Customer__c customer : newMap.values()) {

            if(customer.Status__c != oldMap.get(customer.Id).Status__c) {
                if(customer.Status__c == ConstantUtility.ONBOARDING_STATUS) {
                    customer.Review_Started__c = System.today();
                }
                if(customer.Status__c == ConstantUtility.SENT_TO_APPROVE_STATUS) {
                    customer.Review_Completed__c = System.today();
                }
                if(customer.Status__c == ConstantUtility.ACTIVE_STATUS || customer.Status__c == ConstantUtility.REJECTED_STATUS) {
                    customer.Approved_by__c = customer.Approver_Position__c;
                    customer.Name_Surname__c = customer.Approver__c;
                }
            }
            if(customer.AML_Risk_Level__c != oldMap.get(customer.Id).AML_Risk_Level__c || customer.Score__c != oldMap.get(customer.Id).Score__c) {
                customer.AML_Risk_Matrix_ver__c = getAMLRiskVersion();
            }
        }
    }

    public void onAfterInsert(List<Customer__c> listOfCustomer) {
        createRelatedMonitoringForCustomer(listOfCustomer);
        createRelatedLicenseAndLicenseTypes(listOfCustomer);
    }

    public static String getAMLRiskVersion() {

        return [SELECT Id, AML_Tool_Version__c FROM Form_Setting__c WHERE Form_Type__c = :ConstantUtility.AML_RISK_LEVEL AND Active__c = TRUE].AML_Tool_Version__c;
    }

    public static void createRelatedMonitoringForCustomer(List<Customer__c> listOfCustomer) {

        List<Monitoring__c> listOfMonitoringsForInsert = new List<Monitoring__c>();
        Set<Id> setOfCustomerIds = new Set<Id>();

        for(Customer__c customer : listOfCustomer) {
            setOfCustomerIds.add(customer.Id);
        }

        for(Id idOfCustomer : setOfCustomerIds) {
            listOfMonitoringsForInsert.add(new Monitoring__c(Customer__c = idOfCustomer, Monitoring_Status__c = 'Not Started'));
        }

        insert listOfMonitoringsForInsert;
    
    }

    public static void createRelatedLicenseAndLicenseTypes(List<Customer__c> listOfCustomer) {

        List<License__c> listOfLicensesForInsert = new List<License__c>();
        Set<Id> setOfCustomerIds = new Set<Id>();

        for(Customer__c customer : listOfCustomer) {
            setOfCustomerIds.add(customer.Id);
        }

        for(Id idOfCustomer : setOfCustomerIds) {
            listOfLicensesForInsert.add(new License__c(Customer__c = idOfCustomer));
        }

        insert listOfLicensesForInsert;

        List<License__c> listOfLicenses = [SELECT Id, Customer__c FROM License__c WHERE Customer__c IN: setOfCustomerIds];
        createLicenseTypes(listOfLicenses);
        createLicenseRelatedDocuments(listOfLicenses);
    }

    public static void createLicenseTypes(List<License__c> listOfLicenses) {

        Map<String, Set<String>> mapOfLicenseTypesBySection = getTypesOfLicenseBySection();
        List<License_Type__c> listOfLicenseTypesForInsert = new List<License_Type__c>();

        for(License__c license : listOfLicenses){
            for (String section : mapOfLicenseTypesBySection.keySet()) {
                Set<String> licenseTypes = mapOfLicenseTypesBySection.get(section);
        
                for (String type : licenseTypes) {
                    listOfLicenseTypesForInsert.add(new License_Type__c(Section__c = section, Type__c = type, License__c = license.Id));
                }
            }
        }
        insert listOfLicenseTypesForInsert;
    }

    public static Map<String, Set<String>> getTypesOfLicenseBySection() {

        Map<String, Set<String>> mapOfLicenseTypesBySection = new Map<String, Set<String>>();
        Set<String> setOfPoliciesAndProceduresTypes = new Set<String>();
        Set<String> setOfExampleKycTypes = new Set<String>();

        List<ApplicationFormService.OptionWrapper> listOfTypeValues = ApplicationFormService.getOptionsForPicklist('Type__c', 'License_Type__c');
        for(ApplicationFormService.OptionWrapper type : listOfTypeValues) {
            if(type.label.contains('Example')) {
                setOfExampleKycTypes.add(type.label);
            } else {
                setOfPoliciesAndProceduresTypes.add(type.label);
            }
        }
    
    mapOfLicenseTypesBySection.put('Examples of KYC packs', setOfExampleKycTypes);
    mapOfLicenseTypesBySection.put('Policies & Procedures', setOfPoliciesAndProceduresTypes);

    return mapOfLicenseTypesBySection;
    }

    public static void createLicenseRelatedDocuments(List<License__c> listOfLicenses) {

        List<Document__c> listOfDocumentsForInsert = new List<Document__c>();

        for(License__c license : listOfLicenses) {
            for(String document : ConstantUtility.SET_OF_LICENSE_DOCUMENTS) {
                Document__c recordOfDocument = new Document__c();
                recordOfDocument.Name = document;
                recordOfDocument.License__c = license.Id;
                listOfDocumentsForInsert.add(recordOfDocument);
            }
        }

        insert listOfDocumentsForInsert;
    }
}
