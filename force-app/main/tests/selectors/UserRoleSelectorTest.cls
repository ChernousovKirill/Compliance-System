@IsTest
private class UserRoleSelectorTest {
    @IsTest
    static void getUserRoleByIds() {
        HttpResponseGeneratorMock calloutMock = new HttpResponseGeneratorMock();

        calloutMock.responses.addAll(
            TestMock.getMockCallouts(
                new List<TestMock.ResponseType>{
                    TestMock.ResponseType.TEST_REQUEST_200
                }
            )
        );

        Test.setMock(HttpCalloutMock.class, calloutMock);

        Id testRoleId = [SELECT Id, Name FROM UserRole LIMIT 1].Id;
        Id profileId = [SELECT Id FROM Profile WHERE UserType = :TestConstants.USER_TYPE_STANDARD LIMIT 1].Id;

        User testUser = TestDataFactory.createUser(testRoleId, profileId, TestConstants.TEST_NAME, TestConstants.TEST_NAME);

        List<UserRole> result;

        System.runAs(testUser) {
            TestDataFactory.createSlackConfiguration();

            Test.startTest();
            result = UserRoleSelector.getUserRoleByIds(new Set<Id>{
                UserInfo.getUserRoleId()
            });
            Test.stopTest();
        }

        Assert.areEqual(testRoleId, result[0].Id);
    }
}