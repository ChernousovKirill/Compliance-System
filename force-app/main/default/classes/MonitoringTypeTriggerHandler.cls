public class MonitoringTypeTriggerHandler {

    public void onAfterUpdate(List<Monitoring_Type__c> listOfMonitoringType) {
        updateMonitoringStatus(listOfMonitoringType);
    }
    
    public static void updateMonitoringStatus(List<Monitoring_Type__c> listOfMonitoringType) {

        String finalStatusOfMonitoring;
        Set<Id> setOfIdMonitoring = new Set<Id>();
        List<Monitoring__c> listOfMonitoringsForUpdate = new List<Monitoring__c>();
        Map<Id, Set<String>> mapOfStatusesByMonitoring = new Map<Id, Set<String>>();
        Map<Id, String> mapOfFinalStatusById = new Map<Id, String>();

        for(Monitoring_Type__c monitoring : listOfMonitoringType) {
            setOfIdMonitoring.add(monitoring.Monitoring__c);
        }

        List<Monitoring_Type__c> listOfMonitoringTypes = [SELECT Id, Status__c, Section__c, Type__c, Monitoring__c
                                                    FROM Monitoring_Type__c 
                                                    WHERE Monitoring__c IN : setOfIdMonitoring 
                                                    AND Section__c = 'Periodic KYC Review' 
                                                    AND Type__c != 'Business Model'
                                                    AND Type__c != 'Monthly Turnover volumes'
                                                    AND Type__c != 'Websites'];

        for (Monitoring_Type__c monitoring : listOfMonitoringTypes) {

            Id idOfMonitoringType = monitoring.Monitoring__c;
    
            String statusOfMonitoringType = monitoring.Status__c;
    
            if (mapOfStatusesByMonitoring.containsKey(idOfMonitoringType)) {
                mapOfStatusesByMonitoring.get(idOfMonitoringType).add(statusOfMonitoringType);
            } else {
                Set<String> setOfMonitoringTypeStatuses = new Set<String>{statusOfMonitoringType};
                mapOfStatusesByMonitoring.put(idOfMonitoringType, setOfMonitoringTypeStatuses);
            }
        }

        for (Id monitoringId : mapOfStatusesByMonitoring.keySet()) {

            Set<String> setOfStatuses = mapOfStatusesByMonitoring.get(monitoringId);
            System.debug('setOfStatuses' + setOfStatuses);
            if(setOfStatuses.contains('Rejected')) {
                mapOfFinalStatusById.put(monitoringId, 'Rejected');
            } else if(setOfStatuses.contains('Postponed')) {
                mapOfFinalStatusById.put(monitoringId, 'Postponed');
            } else if(setOfStatuses.size() == 1 && setOfStatuses.contains('Verified')) {
                mapOfFinalStatusById.put(monitoringId, 'Verified');
            } else {
                mapOfFinalStatusById.put(monitoringId, 'Pending');
            }
        }

        for(Id monitoringId : mapOfFinalStatusById.keySet()) {
            listOfMonitoringsForUpdate.add(new Monitoring__c(Id = monitoringId, Monitoring_Status__c = mapOfFinalStatusById.get(monitoringId)));
        }
        System.debug('listOfMonitoringsForUpdate ' +  listOfMonitoringsForUpdate);
        update listOfMonitoringsForUpdate;
    }

}