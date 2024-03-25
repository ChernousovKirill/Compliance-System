public without sharing class HomePageSearchService {
    
    public static List<Account> getAccountRows(String searchKey) {

        searchKey = '%' + searchKey + '%';
        List<Account> listOfAccount = AccountSelector.getAccountRows(searchKey);
        
        return listOfAccount; 
    }

    public static List<Lead> getLeadRows(String searchKey) {

        searchKey = '%' + searchKey + '%';
        List<Lead> listOfLeads = LeadSelector.getLeadRows(searchKey);
        
        return listOfLeads; 
    }
}