@IsTest
private class OpportunityUtilsTest {
    @IsTest
    static void createOpportunity() {
        Map<String, String> oppStageNamePicklistValues = SobjectUtils.getSobjectPickListValues(
            String.valueOf(Opportunity.SObjectType),
            Opportunity.StageName.getDescribe().getName()
        );

        Opportunity opp = new OpportunityBuilder()
            .withName(TestConstants.TEST_NAME)
            .withAccountId(UserInfo.getUserId())
            .withOwnerId(UserInfo.getUserId())
            .withStageName(oppStageNamePicklistValues.values()[0])
            .withCloseDate(Date.today())
            .withRecordTypeId(UserInfo.getUserId())
            .build(false);

        Assert.areEqual(TestConstants.TEST_NAME, opp.Name);
        Assert.areEqual(UserInfo.getUserId(), opp.AccountId);
        Assert.areEqual(UserInfo.getUserId(), opp.OwnerId);
        Assert.areEqual(oppStageNamePicklistValues.values()[0], opp.StageName);
        Assert.areEqual(Date.today(), opp.CloseDate);
        Assert.areEqual(UserInfo.getUserId(), opp.RecordTypeId);
    }

    @IsTest
    static void createOpportunityWithNull() {
        Opportunity opp = new OpportunityBuilder()
            .build(false);

        Assert.isNull(opp.Name);
        Assert.isNull(opp.AccountId);
        Assert.isNull(opp.OwnerId);
        Assert.isNull(opp.StageName);
        Assert.isNull(opp.CloseDate);
        Assert.isNull(opp.RecordTypeId);
    }
}