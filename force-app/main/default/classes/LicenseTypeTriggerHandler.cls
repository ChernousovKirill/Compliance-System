public class LicenseTypeTriggerHandler {
    
    public void onAfterUpdate(List<License_Type__c> listOfLicenseType) {

        List<License_Type__c> listOfPoliciesAndProcedures = new List<License_Type__c>();
        List<License_Type__c> listOfExamplesOfKycPacks = new List<License_Type__c>();

        for(License_Type__c licenseType : listOfLicenseType) {
            if(licenseType.Section__c == 'Policies & Procedures') {
                listOfPoliciesAndProcedures.add(licenseType);
            } else if(licenseType.Section__c == 'Examples of KYC packs') {
                listOfExamplesOfKycPacks.add(licenseType);
            }
        }

        if(!listOfPoliciesAndProcedures.isEmpty()) {
            updateLicenseStatus(listOfPoliciesAndProcedures, 'Policies & Procedures');
        }

        if(!listOfExamplesOfKycPacks.isEmpty()) {
            updateLicenseStatus(listOfExamplesOfKycPacks, 'Examples of KYC packs');
        }
    }

    public static void updateLicenseStatus(List<License_Type__c> listOfLicenseType, String nameOfSection) {

        String finalStatusOfLicense;
        Set<Id> setOfIdLicense = new Set<Id>();
        List<License__c> listOfLicensesForUpdate = new List<License__c>();
        Map<Id, Set<String>> mapOfStatusesByLicense = new Map<Id, Set<String>>();
        Map<Id, String> mapOfFinalStatusById = new Map<Id, String>();

        for(License_Type__c license : listOfLicenseType) {
            setOfIdLicense.add(license.License__c);
        }

        List<License_Type__c> listOfLicenseTypes = [SELECT Id, Status__c, Section__c, Type__c, License__c
                                                    FROM License_Type__c 
                                                    WHERE License__c IN : setOfIdLicense 
                                                    AND Section__c = :nameOfSection];

        for (License_Type__c license : listOfLicenseTypes) {

            Id idOfLicenseType = license.License__c;
    
            String statusOfLicenseType = license.Status__c;
    
            if (mapOfStatusesByLicense.containsKey(idOfLicenseType)) {
                mapOfStatusesByLicense.get(idOfLicenseType).add(statusOfLicenseType);
            } else {
                Set<String> setOfLicenseTypeStatuses = new Set<String>{statusOfLicenseType};
                mapOfStatusesByLicense.put(idOfLicenseType, setOfLicenseTypeStatuses);
            }
        }

        for (Id licenseId : mapOfStatusesByLicense.keySet()) {

            Set<String> setOfStatuses = mapOfStatusesByLicense.get(licenseId);
            if(setOfStatuses.contains('Rejected')) {
                mapOfFinalStatusById.put(licenseId, 'Rejected');
            } else if(setOfStatuses.contains('Postponed')) {
                mapOfFinalStatusById.put(licenseId, 'Postponed');
            } else if(setOfStatuses.size() == 1 && setOfStatuses.contains('Approved')) {
                mapOfFinalStatusById.put(licenseId, 'Approved');
            } else if(setOfStatuses.size() == 2 && setOfStatuses.contains('Approved') && setOfStatuses.contains('Not Applicable')) {
                mapOfFinalStatusById.put(licenseId, 'Approved');
            } else {
                mapOfFinalStatusById.put(licenseId, 'Pending');
            }
        }

        for(Id licenseId : mapOfFinalStatusById.keySet()) {
            if(nameOfSection == 'Policies & Procedures') {
                listOfLicensesForUpdate.add(new License__c(Id = licenseId, Policies_Procedures_Status__c = mapOfFinalStatusById.get(licenseId)));
            } else if(nameOfSection == 'Examples of KYC packs') {
                listOfLicensesForUpdate.add(new License__c(Id = licenseId, Examples_of_KYC_Status__c = mapOfFinalStatusById.get(licenseId)));
            }
        }
        update listOfLicensesForUpdate;
    }
}