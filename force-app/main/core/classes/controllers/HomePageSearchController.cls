public with sharing class HomePageSearchController {
    
    @AuraEnabled
    public static List<Account> getAccountData(String searchKey) {
        try{
            if (searchKey != null) {
                if (Test.isRunningTest() && searchKey == TestConstants.TEST_SEARCH_KEY) {
                    throw new AuraHandledException('Script-thrown exception');
                }
                List<Account> listOfAccounts = HomePageSearchService.getAccountRows(searchKey);
                return listOfAccounts;
                }
            return null;
        } catch (Exception err) {
            LoggerUtil.error('Fetch Records', err, true);
    
            throw new AuraHandledException(err.getMessage());
        }
    }

    @AuraEnabled
    public static List<Lead> getLeadData(String searchKey){
        try{
            if (searchKey != null) {
                if (Test.isRunningTest() && searchKey == TestConstants.TEST_SEARCH_KEY) {
                    throw new AuraHandledException('Script-thrown exception');
                }
                List<Lead> listOfLeads = HomePageSearchService.getLeadRows(searchKey);
                return listOfLeads;
            }
            return null;
        } catch (Exception err) {
            LoggerUtil.error('Fetch Records', err, true);

            throw new AuraHandledException(err.getMessage());
        }
    }
    
}