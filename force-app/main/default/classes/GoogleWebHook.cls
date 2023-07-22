@RestResource(UrlMapping='/google_create_lead')
global without sharing class GoogleWebHook {
    @HttpPost
    global static void send() {
        RestRequest request = RestContext.request;
        Integration_Settings__c settings = Integration_Settings__c.getInstance();
        if (!request.headers.containsKey('api-key') || request.headers.get('api-key') != settings.Google_Form_Api_Key__c) {
            RestResponse response = RestContext.response;
            response.statusCode = 401;
            response.responseBody = Blob.valueOf(JSON.serialize(new Map <String, Object>{
                    'success' => false
            }));
            return;
        }
        if (request.requestBody == null) {
            RestResponse response = RestContext.response;
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.serialize(new Map <String, Object>{
                    'success' => false
            }));
            return;
        }
        String jsonStr = '';
        jsonStr = request.requestBody.toString();
        GoogleForm formData = parseRequest(jsonStr);
        Lead ld = new Lead(
                FirstName = formData.data.name,
                LastName = formData.data.surname,
                Email = formData.data.email,
                Phone = formData.data.phone,
                Website = formData.data.website,
                CompanySize__c = String.valueOf(formData.data.companySize),
                CountryCode__c = formData.data.country,
                PaymentsVolume__c = String.valueOf(formData.data.paymentsVolume),
                Description = formData.data.comment,
                Company = formData.data.companyName,
                LeadSource = 'Marketing: google'
        );
        System.debug(JSON.serialize(ld));
        insert ld;
        RestResponse response = RestContext.response;
        response.statusCode = 200;
        response.responseBody = Blob.valueOf(JSON.serialize(new Map <String, Object>{
                'success' => true
        }));
    }

    public static GoogleForm parseRequest(String json) {
        return (GoogleForm) System.JSON.deserialize(json, GoogleForm.class);
    }

    public class GoogleForm {
        public String id;
        public String referrer;
        public Data data;
    }

    public class Data {
        public String name;
        public String surname;
        public String email;
        public String phone;
        public String website;
        public Integer companySize;
        public String companyName;
        public String country;
        public Integer paymentsVolume;
        public String comment;
    }
}