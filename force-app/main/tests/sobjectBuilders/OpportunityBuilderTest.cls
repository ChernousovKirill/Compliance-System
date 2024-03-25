@IsTest
public class OpportunityBuilderTest {
    private static OpportunityBuilder oppBuilder = new OpportunityBuilder();
    private static final String TEST_TEXT = TestConstants.TEST_NAME;
    private static final String TEST_STAGE_NAME = SobjectUtils.getSobjectPickListValues(
        String.valueOf(Opportunity.SObjectType),
        Opportunity.StageName.getDescribe().getName()
    ).values()[0];

    @IsTest
    static void builder() {
        Opportunity opp = oppBuilder
            .withName(TEST_TEXT)
            .withStageName(TEST_STAGE_NAME)
            .withCloseDate(Date.today())
            .build(true);

        Opportunity newOpp = [SELECT Name, StageName, CloseDate FROM Opportunity WHERE Id = :opp.Id];

        Assert.areEqual(opp.Id, newOpp.Id);
        Assert.areEqual(opp.Name, newOpp.Name);
        Assert.areEqual(opp.StageName, newOpp.StageName);
        Assert.areEqual(opp.CloseDate, newOpp.CloseDate);
        Assert.areEqual(TEST_TEXT, newOpp.Name);
        Assert.areEqual(TEST_STAGE_NAME, newOpp.StageName);
        Assert.areEqual(Date.today(), newOpp.CloseDate);
    }

    @IsTest
    static void builder2() {
        Opportunity opp = oppBuilder
            .build(false);

        opp = oppBuilder
            .withName(TEST_TEXT)
            .withStageName(TEST_STAGE_NAME)
            .withCloseDate(Date.today())
            .build(true);

        Opportunity newOpp = [SELECT Name, StageName, CloseDate FROM Opportunity WHERE Id = :opp.Id];

        Assert.areEqual(opp.Id, newOpp.Id);
        Assert.areEqual(opp.Name, newOpp.Name);
        Assert.areEqual(opp.StageName, newOpp.StageName);
        Assert.areEqual(opp.CloseDate, newOpp.CloseDate);
        Assert.areEqual(TEST_TEXT, newOpp.Name);
        Assert.areEqual(TEST_STAGE_NAME, newOpp.StageName);
        Assert.areEqual(Date.today(), newOpp.CloseDate);
    }

    @IsTest
    static void withId() {
        Id testOppId = TestDataFactory.generateId(Opportunity.getSObjectType());
        Opportunity opp = oppBuilder.withId(testOppId).build(false);

        Assert.areEqual(testOppId, opp.Id);
    }

    @IsTest
    static void withName() {
        Opportunity opp = oppBuilder.withName(TEST_TEXT).build(false);

        Assert.areEqual(TEST_TEXT, opp.Name);
    }

    @IsTest
    static void withAccountId() {
        Id testAccId = TestDataFactory.generateId(Account.getSObjectType());
        Opportunity opp = oppBuilder.withAccountId(testAccId).build(false);

        Assert.areEqual(testAccId, opp.AccountId);
    }

    @IsTest
    static void withStageName() {
        Opportunity opp = oppBuilder.withStageName(TEST_STAGE_NAME).build(false);

        Assert.areEqual(TEST_STAGE_NAME, opp.StageName);
    }

    @IsTest
    static void withCloseDate() {
        Opportunity opp = oppBuilder.withCloseDate(Date.today()).build(false);

        Assert.areEqual(Date.today(), opp.CloseDate);
    }

    @IsTest
    static void withOwnerId() {
        Opportunity opp = oppBuilder.withOwnerId(UserInfo.getUserId()).build(false);

        Assert.areEqual(UserInfo.getUserId(), opp.OwnerId);
    }

    @IsTest
    static void withRecordTypeId() {
        Id testRecordTypeId = TestDataFactory.generateId(RecordType.getSObjectType());
        Opportunity opp = oppBuilder.withRecordTypeId(testRecordTypeId).build(false);

        Assert.areEqual(testRecordTypeId, opp.RecordTypeId);
    }
}