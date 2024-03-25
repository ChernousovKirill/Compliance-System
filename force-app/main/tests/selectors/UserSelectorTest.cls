@IsTest
private class UserSelectorTest {
    @IsTest
    static void getUserRoleByIds() {
        Test.startTest();
        List<User> result = UserSelector.getUserByIds(new Set<Id>{
            UserInfo.getUserId()
        });
        Test.stopTest();

        Assert.areEqual(UserInfo.getUserId(), result[0].Id);
    }

    @IsTest
    static void getDigitalLeadManagers() {
        TriggerHandler.bypass(UserTriggerHandler.class.getName());
        Id testRoleId = [SELECT Id, Name FROM UserRole LIMIT 1].Id;
        Id profileId = [SELECT Id FROM Profile WHERE UserType = :TestConstants.USER_TYPE_STANDARD LIMIT 1].Id;

        User testUser = TestDataFactory.createUser(testRoleId, profileId, TestConstants.TEST_NAME, TestConstants.TEST_NAME, true);
        Group newGroup = TestDataFactory.initGroup(true);
        GroupMember groupMember = TestDataFactory.initGroupMember(newGroup.Id, testUser.Id, true);

        Test.startTest();
        List<User> result = UserSelector.getDigitalLeadManagers();
        Test.stopTest();

        Assert.areEqual(1, result.size());
    }

    @IsTest
    static void getUserByProfile() {
        
        Profile profile = [SELECT Id, Name FROM Profile WHERE UserType = :TestConstants.USER_TYPE_STANDARD LIMIT 1];
        List<User> listOfUsers = [SELECT Id, Email, Profile.Name FROM User WHERE Profile.Name = :profile.Name AND IsActive = TRUE];

        Test.startTest();
        List<User> result = UserSelector.getUserByProfile(profile.Name);
        Test.stopTest();

        Assert.areEqual(listOfUsers.size(), result.size());
    }
}