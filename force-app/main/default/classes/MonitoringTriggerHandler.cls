public class MonitoringTriggerHandler {

    public void onAfterInsert(List<Monitoring__c> listOfMonitoring) {
        createMonitoringTypesForMonitoring(listOfMonitoring);
    }

    public static void createMonitoringTypesForMonitoring(List<Monitoring__c> listOfMonitoring) {

        Map<String, Set<String>> mapOfMonitorinTypesBySection = getTypesOfMonitoringBySection();
        List<Monitoring_Type__c> listOfMonitoringTypesForInsert = new List<Monitoring_Type__c>();

        for(Monitoring__c monitoring : listOfMonitoring){
            for (String section : mapOfMonitorinTypesBySection.keySet()) {
                Set<String> monitoringTypes = mapOfMonitorinTypesBySection.get(section);
        
                for (String type : monitoringTypes) {
                    Monitoring_Type__c monitoringType = new Monitoring_Type__c();
                    monitoringType.Section__c = section;
                    monitoringType.Type__c = type;
                    monitoringType.Monitoring__c = monitoring.Id;
                    if(type != 'Business Model' && type != 'Monthly Turnover volumes' && type != 'Websites' && section == 'Periodic KYC Review') {
                        monitoringType.Status__c = 'Not Started';
                    }

                    listOfMonitoringTypesForInsert.add(monitoringType);
                }
            }
        }
        insert listOfMonitoringTypesForInsert;
    }    
    
    public static Map<String, Set<String>> getTypesOfMonitoringBySection() {

        Map<String, Set<String>> mapOfMonitorinTypesBySection = new Map<String, Set<String>>();
        List<ApplicationFormService.OptionWrapper> listOfSectionValues = ApplicationFormService.getOptionsForPicklist('Section__c', 'Monitoring_Type__c');
        System.debug('logLevel' + listOfSectionValues);
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