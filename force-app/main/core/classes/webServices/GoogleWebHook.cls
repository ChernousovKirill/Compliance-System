@RestResource(UrlMapping='/google_create_lead')
global without sharing class GoogleWebHook {
    private static final String SUCCESS;
    private static final String DIGITAL_MARKETING;
    private static final String SCORE;
    private static final String LEAD_ID;
    private static final String EMAIL;
    private static final String WEBSITE;

    static {
        SUCCESS = ConstantUtility.SUCCESS;
        DIGITAL_MARKETING = ConstantUtility.DIGITAL_MARKETING;
        SCORE = ConstantUtility.SCORE;
        LEAD_ID = ConstantUtility.LEAD_ID;
        EMAIL = ConstantUtility.EMAIL;
        WEBSITE = ConstantUtility.WEBSITE;
    }

    public static LeadUtils leadUtilsCls {
        get {
            if (leadUtilsCls == null) {
                leadUtilsCls = new LeadUtils();
            }

            return leadUtilsCls;
        }
        set;
    }

    public static CountryUtils countryUtilsCls {
        get {
            if (countryUtilsCls == null) {
                countryUtilsCls = new CountryUtils();
            }

            return countryUtilsCls;
        }
        set;
    }

    public static Integration_Settings__c settings = SettingUtils.integrationSettings;

    @HttpGet
    global static void getLead() {
        RestRequest request = RestContext.request;

        if (HttpRequestService.validateRequestHeader(request.headers)) {
            return ;
        }

        try {
            List<Lead> lead = LeadSelector.getLeadByEmailAndWebsite(
                request.params.get(EMAIL)
            );

            RestResponse response = RestContext.response;

            if (lead.isEmpty()) {
                response.statusCode = 404;
            } else {
                response.statusCode = 200;
                response.responseBody = Blob.valueOf(JSON.serialize(new Map <String, Object>{
                    SUCCESS => true,
                    SCORE => lead[0].Score_Formula__c,
                    LEAD_ID => lead[0].Id
                }));
            }
        } catch (Exception e) {
            throw new HandledException(e.getMessage());
        }
    }

    @HttpPost
    global static void send() {
        RestRequest request = RestContext.request;

        if (HttpRequestService.validateRequestHeader(request.headers)) {
            return ;
        }

        if (validateRequestBody(request.requestBody)) {
            return ;
        }

        String jsonStr = request.requestBody.toString();
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
            LeadSource = DIGITAL_MARKETING,
            UTMSource__c = formData.advTags.utm_source,
            UTMMeduim__c = formData.advTags.utm_medium,
            UTMCampaign__c = formData.advTags.utm_campaign,
            UTMContent__c = formData.advTags.utm_content,
            UTMTerm__c = formData.advTags.utm_term,
            customclid__c = formData.advTags.customclid,
            gclid__c = formData.advTags.gclid
        );

        if (formData.data.website != null) {
            Map<Boolean, Map<String, String>> isSupportedBanksToCountryNameCountryCode = countryUtilsCls.getCountryCodeOfSupportedCountries();

            ld = leadUtilsCls.updateIndustryOfLead(ld);
            ld = leadUtilsCls.updateTrafficOfLead(ld, isSupportedBanksToCountryNameCountryCode);
        }

        System.debug(JSON.serialize(ld));
        insert ld;

        Decimal leadScore = LeadSelector.getLeadScore(ld.Id);

        sendMessage(ld, formData, leadScore);

        RestResponse response = RestContext.response;
        response.statusCode = 200;
        response.responseBody = Blob.valueOf(JSON.serialize(new Map <String, Object>{
            SUCCESS => true,
            SCORE => leadScore
        }));
    }

    public static GoogleForm parseRequest(String json) {
        return (GoogleForm) System.JSON.deserialize(json, GoogleForm.class);
    }

    private static Boolean validateRequestBody(Blob requestBody) {
        Boolean isNotValid = false;

        if (requestBody == null || requestBody.toString() == '') {
            RestResponse response = RestContext.response;
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.serialize(new Map <String, Object>{
                SUCCESS => false
            }));

            isNotValid = true;
        }

        return isNotValid;
    }

    private static void sendMessage(Lead lead, GoogleForm formData, Decimal leadScore) {
        List<String> body = buildMessageToSlack(lead, formData, leadScore).split('<br/>');

        sendMessageToSlack(String.join(body, '\n'));
    }

    @Future(Callout=true)
    private static void sendMessageToSlack(String messageForSlack) {
        SlackNotificationRestService.sendMessageToDigitalLeadSlack(messageForSlack) ;
    }

    private static String buildMessageToSlack(Lead lead, GoogleForm formData, Decimal leadScore) {
        Noda_Custom_Settings__c settingsOfNoda = SettingUtils.settingsOfNoda;

        String link = settingsOfNoda.Org_URL__c + lead.Id;
        String message = String.format(Label.newDigitalLeadTemplate, new List<Object>{lead.FirstName, lead.LastName, lead.Email, lead.Phone, 
                                                                                        lead.Company, lead.Website, lead.CompanySize__c, lead.CountryCode__c,
                                                                                        lead.PaymentsVolume__c, lead.Description, formData.data.preferredServices,
                                                                                        lead.UTMSource__c, lead.UTMMeduim__c, lead.UTMCampaign__c, link, leadScore
        });
        return message;
    }

    public class GoogleForm {
        public String id;
        public String referrer;
        public Data data;
        public AdvTags advTags;
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
        public List<Integer> preferredServices;
    }

    public class AdvTags {
        public String utm_source;
        public String utm_medium;
        public String utm_campaign;
        public String utm_content;
        public String utm_term;
        public String customclid;
        public String gclid;
    }
}