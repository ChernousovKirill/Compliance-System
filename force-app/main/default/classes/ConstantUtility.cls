public class ConstantUtility {

    public static final String NAME_OF_BACKUP = 'Daily_Backup_';
    public static final String BACKUP_TYPE = 'Backup';
    public static final String SUCCESSFUL_EMOJI = '\u2705';
    public static final String ERROR_EMOJI = '\u274C';
    public static final String ERROR_MESSAGE = 'The request failed. Status code:';
    public static final String SUCCESSFUL_MESSAGE = 'Backup completed successfully';
    public static final String NAME_OF_STORAGE = 'backupforsalesforce';
    public static final String NAME_OF_CONTAINER = 'salesforcebackuptest';
    public static final String URL_OF_AZURE = '.blob.core.windows.net/';
    public static final String STORAGE_KEY = 'UlEeVrGVKXDCjJDHZEPMkK6Ppw97qtWG0uRPybxxFlVs2JTJdpBJRIGWf1wH7Xn5HXS0fbA4mx5S+AStj63uMg==';
    public static final String TYPE_OF_ZIP_FILE = 'application/zip';
    public static final String ACCOUNT = 'Account';
    public static final String LEAD = 'Lead';
    public static final String CONTACT = 'Contact';
    public static final String OPPORTUNITY = 'Opportunity';
    public static final String RESELLER = 'Reseller';
    public static final String CUSTOMER = 'Customer__c';

    public static final String HEAD_OF_MERCHANT = 'Head of Merchant Onboarding Team';
    public static final String CHIEF_COMPLIANCE = 'Chief Compliance Officer/MLRO';
    public static final String SYSTEM_ADMINISTRATOR = 'System Administrator';
    public static final String AML_OFFICER = 'AML Officer';

    public static final String HIGH_RISK = 'High Risk';
    public static final String MEDIUM_RISK = 'Medium Risk';
    public static final String LOW_RISK = 'Low Risk';
    public static final String LWC_ERROR = 'LWC Error';

    public static final String PICKLIST = 'PICKLIST'; 
    public static final String LISTBOX = 'LISTBOX'; 
    public static final String BLANK = 'BLANK';
    public static final String TEXT = 'TEXT';
    public static final String CHECKBOX = 'CHECKBOX';
    public static final String REFERENCE = 'REFERENCE'; 
    public static final String TEXTAREA = 'TEXTAREA'; 
    public static final String CURRENCY_TYPE = 'CURRENCY'; 
    public static final String NUMBER_TYPE = 'NUMBER'; 
    public static final String DATE_TYPE = 'DATE';
    public static final String DATE_TIME_TYPE = 'DATETIME'; 
    public static final String DOUBLE_TYPE = 'DOUBLE';
    public static final String MULTIPICKLIST = 'MULTIPICKLIST';


    public static final String COUNTRY = 'Country'; 
    public static final String GEOGRAPHICAL_RISK = 'Geographical Risk';
    public static final String COUNTRY_OF_INCORPORATION = 'Country_of_incorporation_of_the_Corpora__c';
    public static final String COUNTRY_OF_CITIZENSHIP = 'Country_of_citizenship_of_UBO__c';  
    public static final String NATIONALITY_OF_UBO = 'Nationality_of_UBO__c';
    public static final String COUNTRY_OF_RESIDENCE = 'Country_of_residence_of_UBO__c';
    public static final String OTHER_INDUSTRY = 'Other_Business_Industry_Activity__c'; 
    public static final String MONTH_FIELD = 'Month__c'; 
    public static final String MONTH_TRANSACTION ='Month_Transaction__c';
    public static final String DATE_OF_AML = 'Date_of_AML__c';

    public static final String SENT_STATUS = 'Sent'; 
    public static final String ONBOARDING_STATUS = 'Onboarding';   
    public static final String SENT_TO_APPROVE_STATUS = 'Sent to Approve';
    public static final String ACTIVE_STATUS = 'Active';
    public static final String REJECTED_STATUS = 'Rejected';
    public static final String ANSWERED_STATUS = 'Answered';
    public static final String APPROVED_STATUS = 'Approved';
    public static final String BANK_ACCOUNTS = 'Bank Accounts';

    public static final String AML_RISK_LEVEL = 'AML Risk Level';
    public static final String AML_RISK_ASSESSMENT = 'Customer Risk Assessment';
    public static final String LAST_MONTHS_TRANSACTIONS = 'Last Months Transactions';
    public static final String DETAILS_PAGE = 'Details Page';
    public static final String OTHER = 'Other';
    public static final String ENHANCED_CDD = 'Enhanced CDD';
    public static final String MONTH = 'Month';
    public static final String AMOUNT = 'Amount';

    public static final String TEMPLATE_FOR_LEADS_WITHOUT_SCORE = 'Noda_Email_When_Score_0';

    public static final String DOCTYPE_UNKNOWN = 'doctype:unknown';

    public static final Integer MAXIMUM_NUMBER_OF_COUNTRIES = 3;

    public static final List<String> AML_RISK_SECTION_FIELDS = new List<String>{
        'Enhanced_Periodic_KYC__c',
        'SOW_SOF__c',
        'Compliance_policies__c',
        'Enhanced_Webshield__c',
        'License__c',
        'Enhnaced_Sanction_Screening__c',
        'Certified_Documents__c',
        'Enhanced_TM__c',
        'Certified_Organizational_Chart__c',
        'MLRO_Approval__c'
    };

    public static final Set<String> SET_OF_MONITORING_SECTION_TYPES = new Set<String>{
        'Good Standing Dates', 'Corporate Doc. Update', 'Government Doc. Update', 'UBO Passport expiry date',
        'Annual Accounts', 'AML Watchlists', 'Power of Attorney expiry date', 'Trust Agreement expiry date',
        'License expiry date', 'Follow-up', 'Ongoing Monitoring'
    };

    public static final Set<String> SET_OF_KYC_REVIEW_SECTION_TYPES = new Set<String>{
        'Business Model','Monthly Turnover volumes', 'Websites', 'Corporate Doc. Update', 'Government Doc. Update', 'Directors, Auth.Sign.',
        'UBO', 'License', 'Bank Account', 'Financial Accounts', 'Website Checks', 'Screening', 'AML Risk Level'
    };

    public static final Set<String> SET_OF_UBO_DOCUMENTS = new Set<String>{
        'SOF','SOW', 'CV of UBO'
    };

    public static final Set<String> SET_OF_INDIVIDUAL_DOCUMENTS = new Set<String>{
        'Proof of Identity', 'Proof of Residence', 'Document of Trust'
    };

    public static final Set<String> SET_OF_CORPORATE_DIRECTOR_DOCUMENTS = new Set<String>{
        'Certificate of Incorporation','Register of Directors', 'Document of Trust'
    };

    public static final Set<String> SET_OF_INDIVIDUAL_GOVERNMENT_DOCUMENTS = new Set<String>{
        'Excerpt from the Business Register'
    };

    public static final Set<String> SET_OF_CORPORATE_GOVERNMENT_DIRECTOR_DOCUMENTS = new Set<String>{
        'Excerpt from the Business Register','Registered Directors'
    };

    public static final Set<String> SET_OF_CORPORATE_KYC_DOCUMENTS = new Set<String>{
        'Certificate of Incorporation', 'M&A', 'Register of Shareholders', 'Document of Trust'
    };
    public static final Set<String> SET_OF_GOVERNMENT_KYC_DOCUMENTS = new Set<String>{
        'Excerpt from the Business Register', 'Registered Directors', 'Registered Shareholders'
    };

    public static final Set<String> SET_OF_EXISTING_ICONS = new Set<String>{
        'ai','attachment','audio','box_notes','csv','eps','excel','exe',
        'flash','folder','gdoc','gdocs','gform','gpres','gsheet','html',
        'keynote','library_folder','image','link','mp4','overlay','pack',
        'pages','pdf','ppt','psd','quip_doc','quip_sheet','xml','visio',
        'rtf','slide','stypi','txt','video','zip','webex','word','quip_slide'
    };

    public static final Set<String> SET_OF_SECTION_WITH_LICENSE_MONITORING_TYPES = new Set<String> { 
        'Examples of KYC packs',
        'Policies & Procedures'
    };

    public static final Set<String> SET_OF_LICENSE_DOCUMENTS = new Set<String> { 
        'Provided Licence',
        'Excerpt from the Regulator Register',
        'Service Agreement between Payment Agent and License Holder'
    };

}