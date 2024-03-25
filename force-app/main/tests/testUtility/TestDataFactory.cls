@IsTest
public class TestDataFactory {
    private static Integer fakeIdCount = 0;
    private static final String ID_PATTERN = '000000000000';

    private final String random_name_postfix {
        get {
            if (random_name_postfix == null) {
                random_name_postfix = String.valueOf(Math.random()).substring(2, 8);
            }

            return random_name_postfix;
        }

        set;
    }

    public static Lead initLead(Boolean doInsert) {
        Lead newLead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company'
        );

        if (doInsert) {
            insert newLead;
        }

        return newLead;
    }

    public static EmailTemplate initEmailTemplate(Id folderId, Boolean doInsert) {
        EmailTemplate testTemplate = new EmailTemplate(Name='Test Template', 
                                                        FolderId = folderId, 
                                                        TemplateType = 'text', 
                                                        Subject = 'Test Email',
                                                        DeveloperName= TestConstants.TEMPLATE_DEVELOPER_NAME
                                                        );

        if (doInsert) {
            insert testTemplate;
        }

        return testTemplate;
    }

    public static Country__c initCountry(String countryName, String countryCode, Boolean isSupportedBank, Boolean doInsert) {
        Country__c newCountry = new Country__c(
            Name = countryName,
            Country_Code__c = countryCode,
            Is_country_with_supported_banks__c = isSupportedBank
        );

        if (doInsert) {
            insert newCountry;
        }

        return newCountry;
    }

    public static Group initGroup(Boolean doInsert) {
        Group newGroup = new Group(
            Name = ConstantUtility.DIGITAL_LEAD_GROUP
        );

        if (doInsert) {
            insert newGroup;
        }

        return newGroup;
    }

    public static GroupMember initGroupMember(Id groupId, Id userId, Boolean doInsert) {
        GroupMember newGroupMember = new GroupMember(
                    GroupId = groupId,
                    UserOrGroupId = userId
        );

        if (doInsert) {
            insert newGroupMember;
        }

        return newGroupMember;
    }

    public static List<Lead> initLeads(Integer numberOfRecords, Boolean doInsert) {
        List<Lead> testLeads = new List<Lead>();

        for (Integer i = 0; i<numberOfRecords; i++) {
            testLeads.add(initLeadWithActivityDate(false));
        }

        if (doInsert) {
            insert testLeads;
        }

        return testLeads;
    }

    public static List<Lead> initLeads(Integer numberOfRecords, String preferredServices, String prod, Boolean doInsert) {
        List<Lead> testLeads = new List<Lead>();

        for (Integer i = 0; i<numberOfRecords; i++) {
            testLeads.add(initLead(i, preferredServices, prod, false));
        }

        if (doInsert) {
            insert testLeads;
        }

        return testLeads;
    }

    public static Lead initLead(Integer recordNumber, String preferredServices, String prod, Boolean doInsert) {
        Lead newUbo = new Lead(
            Website = 'www.example' + recordNumber + '.com',
            LastName = 'LastName',
            Company = 'Company',
            PrefferedServices__c = preferredServices,
            Product__c = prod
        );

        if (doInsert) {
            insert newUbo;
        }

        return newUbo;
    }

    public static Lead initLeadWithActivityDate(Boolean doInsert) {
        Date activityDate = Date.today();

        Lead newLead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            Activity_Date__c = activityDate
        );

        if (doInsert) {
            insert newLead;
        }

        return newLead;
    }

    public static List<Task> initTasks(Integer numberOfRecords, Id testLeadId, Boolean doInsert) {
        List<Task> tasks = new List<Task>();

        for (Integer i = 0; i<numberOfRecords; i++) {
            tasks.add(initTask(i + 1, testLeadId, false));
        }

        if (doInsert) {
            insert tasks;
        }

        return tasks;
    }

    public static Task initTask(Integer recordNumber, Id testLeadId, Boolean doInsert) {
        Task newTask = new Task(Subject = 'Test Task ' + recordNumber, WhoId = testLeadId, ActivityDate = Date.today());

        if (doInsert) {
            insert newTask;
        }

        return newTask;
    }

    public static List<Account> createAccounts(Boolean doInsert, Integer numberOfRecords) {
        List<Account> accounts = new List<Account>();
        accounts = new List<Account>();

        for (Integer i = 0; i<numberOfRecords; i++) {
            Account newAcc = new TestDataFactory.AccountBuilder()
                .withName(TestConstants.TEST_NAME + i)
                .build(false);

            accounts.add(newAcc);
        }

        if (doInsert) {
            insert accounts;
        }

        return accounts;
    }

    public static List<Opportunity> createOpportunities(Boolean doInsert, List<Account> accounts) {
        List<Opportunity> opportunities = new List<Opportunity>();
        List<String> oppTypes = new List<String>{'Noda Go', 'Noda Buffet'};

        for (Account account : accounts) {
            for (String type : oppTypes) {
                Opportunity newOpp = new TestDataFactory.OpportunityBuilder()
                    .withName(account.Name + ' - ' + type)
                    .withAccount(account.Id)
                    .withStage()
                    .withCloseDate(Date.today())
                    .withServiceType(type)
                    .build(false);
    
                    opportunities.add(newOpp);
            }
        }

        if (doInsert) {
            insert opportunities;
        }

        return opportunities;
    }

    public static User createUser(String roleId, String profId, String firstName, String lastName, Boolean doInsert) {
        String randomName = new TestDataFactory().random_name_postfix + 'user@test.user.com';

        User tempUser = new User(
            FirstName = firstName,
            LastName = lastName,
            Email = randomName,
            Username = randomName,
            EmailEncodingKey = 'ISO-8859-1',
            Alias = 'user' + randomName.substring(0, 4),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = profId
        );

        if (String.isBlank(roleId) == false) {
            tempUser.UserRoleId = roleId;
        }

        if(doInsert) {
            insert tempUser;
        }

        return tempUser;
    }

    public static void createNodaCustomSetting() {
        insert new Noda_Custom_Settings__c(
            Name = TestConstants.TEST_NAME,
            Domainst_Black_List__c = TestConstants.NODA_CS_DOMAINS_BLACK_LIST,
            Org_URL__c = TestConstants.NODA_CS_ORG_URL,
            Jira_Api_Token__c = TestConstants.NODA_CS_JIRA_API_TOKEN,
            Jira_Project_Key__c = TestConstants.NODA_CS_JIRA_PROJECT_KEY,
            Jira_Url__c = TestConstants.NODA_CS_JIRA_URL,
            Jira_Username__c = TestConstants.NODA_CS_JIRA_USERNAME,
            Standard_Opportunity__c = TestConstants.NODA_CS_STANDARD_OPPORTUNITY,
            Upsale_Opportunity__c = TestConstants.NODA_CS_UP_SALE_OPPORTUNITY
        );
    }

    public static void createSlackConfiguration() {
        insert new Slack_Configuration__c(
            Name = TestConstants.TEST_NAME,
            Post_Message_URL__c = TestConstants.TEST_SITE_URL,
            Bot_Token__c = TestConstants.SLACK_BOT_TOKEN,
            Channel_Name__c = TestConstants.SLACK_CHANNEL_NAME,
            Digital_Lead_Channel__c = TestConstants.DIGITAL_SLACK_CHANNEL_NAME

        );
    }

    public static void createIntegrationSettings() {
        insert new Integration_Settings__c(
            Google_Form_Api_Key__c = TestConstants.INTEGRATION_KEY
        );
    }

    public static Id generateId(Schema.SObjectType sobjectType) {
        String keyPrefix = sobjectType.getDescribe().getKeyPrefix();
        fakeIdCount++;

        String fakeIdPrefix = ID_PATTERN.substring(0, ID_PATTERN.length() - String.valueOf(fakeIdCount).length());

        return Id.valueOf(keyPrefix + fakeIdPrefix + fakeIdCount);
    }

    public with sharing class AccountBuilder {
        public Account acc = new Account();

        public AccountBuilder() {
        }

        public AccountBuilder(Account acc) {
            this.acc = acc;
        }

        public Account build(Boolean doInsert) {
            Account newAcc = new Account();

            if (this.acc.Name != null) {
                newAcc.Name = this.acc.Name;
            }

            if (this.acc.New_Comment__c != null) {
                newAcc.New_Comment__c = this.acc.New_Comment__c;
            }

            if (this.acc.Activity_Date__c != null) {
                newAcc.Activity_Date__c = this.acc.Activity_Date__c;
            }

            if (doInsert) {
                insert newAcc;
            }

            return newAcc;
        }

        public TestDataFactory.AccountBuilder withName(String name) {
            this.acc.Name = name;
            return this;
        }

        public TestDataFactory.AccountBuilder withComment() {
            this.acc.New_Comment__c = TestConstants.TEST_COMMENT;
            return this;
        }

        public TestDataFactory.AccountBuilder withActivityDate() {
            this.acc.Activity_Date__c = Date.today();
            return this;
        }
    }

    public with sharing class OpportunityBuilder {
        public Opportunity opp = new Opportunity();

        public OpportunityBuilder() {
        }

        public OpportunityBuilder(Opportunity opp) {
            this.opp = opp;
        }

        public Opportunity build(Boolean doInsert) {
            Opportunity newOpp = new Opportunity();

            if (this.opp.Name != null) {
                newOpp.Name = this.opp.Name;
            }

            if (this.opp.AccountId != null) {
                newOpp.AccountId = this.opp.AccountId;
            }

            if (this.opp.StageName != null) {
                newOpp.StageName = this.opp.StageName;
            }

            if (this.opp.CloseDate != null) {
                newOpp.CloseDate = this.opp.CloseDate;
            }

            if (this.opp.Service_Type__c != null) {
                newOpp.Service_Type__c = this.opp.Service_Type__c;
            }

            if (doInsert) {
                insert newOpp;
            }

            return newOpp;
        }

        public TestDataFactory.OpportunityBuilder withName(String name) {
            this.opp.Name = name;
            return this;
        }

        public TestDataFactory.OpportunityBuilder withAccount(String accountId) {
            this.opp.AccountId = accountId;
            return this;
        }

        public TestDataFactory.OpportunityBuilder withStage() {
            this.opp.StageName = TestConstants.TEST_NEGOTIATION_STAGE;
            return this;
        }

        public TestDataFactory.OpportunityBuilder withCloseDate(Date today) {
            this.opp.CloseDate = today.addMonths(1);
            return this;
        }

        public TestDataFactory.OpportunityBuilder withServiceType(String serviceType) {
            this.opp.Service_Type__c = serviceType;
            return this;
        }
    }
}