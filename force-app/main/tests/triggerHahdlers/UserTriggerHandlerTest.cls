@IsTest
private class UserTriggerHandlerTest {
    @TestSetup
    static void setup() {
        HttpResponseGeneratorMock calloutMock = new HttpResponseGeneratorMock();

        calloutMock.responses.addAll(
            TestMock.getMockCallouts(
                new List<TestMock.ResponseType>{
                    TestMock.ResponseType.SEND_SLACK_MESSAGE_200
                }
            )
        );

        Test.setMock(HttpCalloutMock.class, calloutMock);
    }

    @IsTest
    static void createUserShouldThrowError() {

        Id testRoleId = [SELECT Id, Name FROM UserRole LIMIT 1].Id;
        Id profileId = [SELECT Id FROM Profile WHERE UserType = :TestConstants.USER_TYPE_STANDARD LIMIT 1].Id;

        User testUser = TestDataFactory.createUser(testRoleId, profileId, TestConstants.TEST_NAME, TestConstants.TEST_NAME, false);

        try {
            Test.startTest();
            insert testUser ;
            Test.stopTest();

            Assert.fail();
        } catch (Exception e) {
            Assert.isTrue(e.getMessage() .contains('cannot be null'));
        }
    }

    @IsTest
    static void createUser() {
        TestDataFactory.createSlackConfiguration();

        Id profileId = [SELECT Id FROM Profile WHERE Name = :TestConstants.SYSTEM_ADMINISTRATOR LIMIT 1].Id;
        User testAdm = TestDataFactory.createUser('', profileId, TestConstants.TEST_NAME, TestConstants.TEST_NAME,false);

        System.runAs (testAdm) {
            Boolean isError = false;

            Id profileId2 = [SELECT Id FROM Profile WHERE UserType = :TestConstants.USER_TYPE_STANDARD LIMIT 1].Id;

            User newUser = TestDataFactory.createUser('', profileId2, TestConstants.TEST_NAME, TestConstants.TEST_NAME, false);

            try {
                Test.startTest();
                insert newUser;
                Test.stopTest();
            } catch (Exception e) {
                isError = true;
            }

            User result = [SELECT Id, ProfileId FROM User WHERE Id = :newUser.Id];

            Assert.isFalse(isError);
            Assert.areEqual(newUser.ProfileId, result.ProfileId);
        }
    }

    @IsTest
    static void updateUserRole() {
        TestDataFactory.createSlackConfiguration();

        Id profileId = [SELECT Id FROM Profile WHERE Name = :TestConstants.SYSTEM_ADMINISTRATOR LIMIT 1].Id;
        User testAdm = TestDataFactory.createUser('', profileId, TestConstants.TEST_NAME, TestConstants.TEST_NAME, false);

        System.runAs (testAdm) {
            Boolean isError = false;

            Id profileId2 = [SELECT Id FROM Profile WHERE UserType = :TestConstants.USER_TYPE_STANDARD LIMIT 1].Id;
            UserRole testRole = [SELECT Id, Name FROM UserRole LIMIT 1];

            User newUser = TestDataFactory.createUser('', profileId2, TestConstants.TEST_NAME, TestConstants.TEST_NAME, false);
            insert newUser;

            newUser.UserRoleId = testRole.Id;

            try {
                Test.startTest();
                update newUser;
                Test.stopTest();
            } catch (Exception e) {
                isError = true;
            }

            User result = [SELECT Id, UserRoleId FROM User WHERE Id = :newUser.Id];

            Assert.isFalse(isError);
            Assert.areEqual(testRole.Id, result.UserRoleId);
        }
    }

    @IsTest
    static void updateUserProfile() {
        TestDataFactory.createSlackConfiguration();

        Id profileId = [SELECT Id FROM Profile WHERE Name = :TestConstants.SYSTEM_ADMINISTRATOR LIMIT 1].Id;
        User testAdm = TestDataFactory.createUser('', profileId, TestConstants.TEST_NAME, TestConstants.TEST_NAME, false);

        System.runAs (testAdm) {
            Boolean isError = false;

            Id profileId2 = [SELECT Id FROM Profile WHERE UserType = :TestConstants.USER_TYPE_STANDARD LIMIT 1].Id;

            User newUser = TestDataFactory.createUser('', profileId2, TestConstants.TEST_NAME, TestConstants.TEST_NAME, false);
            insert newUser;

            newUser.ProfileId = profileId;

            try {
                Test.startTest();
                update newUser;
                Test.stopTest();
            } catch (Exception e) {
                isError = true;
            }

            User result = [SELECT Id, ProfileId FROM User WHERE Id = :newUser.Id];

            Assert.isFalse(isError);
            Assert.areEqual(ProfileId, result.ProfileId);
        }
    }
}