public class SimilarWebRestApiService {

    private static final String API_KEY = 'e05694aeda644369b616d232af908380';
    private static final String API_BASE_URL = 'https://api.similarweb.com/v4/website/';

    private static final String API_BASE_URL_INDUSTRY = 'https://api.similarweb.com/v1/website/';

    public static  Map<String, String>  getCountryAndTrafficFromWebsite(String websiteUrl, Map<String, String> mapOfSupportedCountryCodeByName, Map<String, String> mapOfUnsupportedCountryCodeByName) {
        String previousMonth = getPreviousMonth();
        Map<String, String> mapOfTrafficByCountryCode = new Map<String,String>();
        String apiUrl = API_BASE_URL + websiteUrl + '/geo/total-traffic-by-country?api_key=' + API_KEY + '&start_date=' + previousMonth + '&end_date=' + previousMonth;
        String valueOfSupportedGeoField = '';
        String valueOfUnsupportedGeoField = '';
        Decimal valueOfSupportedTraffic = 0;
        Decimal valueOfGeneralTraffic = 0;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiUrl);
        request.setMethod('GET');
        request.setHeader('User-Agent', 'Salesforce');
        request.setHeader('Authorization', 'Bearer ' + API_KEY);
    
        try {
            HttpResponse response = new Http().send(request);
            System.debug('response ' + response);
            if (response.getStatusCode() == 200) {
                Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());    
                List<Object> records = (List<Object>) responseData.get('records');
                System.debug('records ' + records);
                if (!records.isEmpty()) {
                    
                    for (Integer i = 0; i < records.size(); i++) {
                        Map<String, Object> record = (Map<String, Object>) records[i];
                        String countryName = (String) record.get('country_name');
                        if(mapOfSupportedCountryCodeByName.containsKey(countryName)) {
                            valueOfSupportedGeoField += mapOfSupportedCountryCodeByName.get(countryName) + ';';
                            valueOfSupportedTraffic += (Decimal) record.get('visits');
                            valueOfGeneralTraffic += (Decimal) record.get('visits');
                        } else {
                            valueOfUnsupportedGeoField += mapOfUnsupportedCountryCodeByName.get(countryName) + ';';
                            valueOfGeneralTraffic += (Decimal) record.get('visits');
                        }
                    }
                    mapOfTrafficByCountryCode.put('valueOfSupportedGeoField', valueOfSupportedGeoField);
                    mapOfTrafficByCountryCode.put('valueOfSupportedTraffic', String.valueOf(valueOfSupportedTraffic));
                    mapOfTrafficByCountryCode.put('valueOfUnsupportedGeoField', valueOfUnsupportedGeoField);
                    mapOfTrafficByCountryCode.put('valueOfGeneralTraffic', String.valueOf(valueOfGeneralTraffic));

                    return mapOfTrafficByCountryCode;
                } else {
                    LogService.saveApexLog('SimilarWeb Api Error', 'Error', Datetime.now(), JSON.serialize(response));
                    return mapOfTrafficByCountryCode;
                }
            }
        } catch (Exception ex) {
            LogService.saveApexLog('SimilarWeb Api Error', 'Error', Datetime.now(), ex.getMessage());
        }
        return mapOfTrafficByCountryCode;
    }
    

    public static String getIndustryOfWebsite(String websiteUrl) {
        String apiUrl = API_BASE_URL_INDUSTRY + websiteUrl + '/category-rank/category-rank?api_key=' + API_KEY;
        String nameOfCategory;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiUrl);
        request.setMethod('GET');
        request.setHeader('User-Agent', 'Salesforce');
        request.setHeader('Authorization', 'Bearer ' + API_KEY);

        try {
            HttpResponse response = new Http().send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                nameOfCategory = (String) responseData.get('category');
                return nameOfCategory.replace('_', ' ');
            } else {
                return '';
            }
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }

    public static String getPreviousMonth() {
        Date today = Date.today();
        Date lastDayOfPreviousMonth;
        System.debug('today.day() ' + today.day());
        if (today.day() <= 15) {
            lastDayOfPreviousMonth = today.addMonths(-2).toStartOfMonth();
        } else {
            lastDayOfPreviousMonth = today.addMonths(-1).toStartOfMonth();
        }
    
        String previousMonth = lastDayOfPreviousMonth.year() + '-' + String.valueOf(lastDayOfPreviousMonth.month()).leftPad(2, '0');
        return previousMonth;
    }
    
}