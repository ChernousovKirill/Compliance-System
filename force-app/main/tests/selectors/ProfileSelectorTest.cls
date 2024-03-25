@IsTest
private class ProfileSelectorTest {
    @IsTest
    static void getProfileByIds() {
        Test.startTest();
        List<Profile> result = ProfileSelector.getProfileByIds(new Set<Id>{UserInfo.getProfileId()});
        Test.stopTest();

        Assert.areEqual(UserInfo.getProfileId(), result[0].Id);
    }
}