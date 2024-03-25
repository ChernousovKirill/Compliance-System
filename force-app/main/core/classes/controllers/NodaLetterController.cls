public class NodaLetterController {

    public string getStrLogoUrl() {
        return getUrlByDocumentName('NodaLogo');
    }

    public String getUrlByDocumentName(String nameOfDocument) {
        String urlOfLogo = null;

        for(Document logo: [SELECT Id FROM Document WHERE DeveloperName = :nameOfDocument LIMIT 1]){

            String idOfOrganization = UserInfo.getOrganizationId();
            Noda_Custom_Settings__c nodaCustomSettings = Noda_Custom_Settings__c.getOrgDefaults();
            String urlOfOrg = '/';
            if(nodaCustomSettings != null && nodaCustomSettings.Org_URL__c!=null) {
                urlOfOrg = nodaCustomSettings.Org_URL__c;
            }

            urlOfLogo = urlOfOrg + 'servlet/servlet.ImageServer?id=' + logo.Id + '&oid=' + idOfOrganization;
        }
        System.debug('urlOfLogo ' + urlOfLogo);
        return urlOfLogo;
    }
}