@IsTest
private class SlackNotificationRestServiceTest {
    @IsTest
    static void testBehaviorNegative() {
        HttpResponseGeneratorMock calloutMock = new HttpResponseGeneratorMock();

        calloutMock.responses.addAll(
            TestMock.getMockCallouts(
                new List<TestMock.ResponseType>{
                    TestMock.ResponseType.TEST_REQUEST_200
                }
            )
        );

        Test.setMock(HttpCalloutMock.class, calloutMock);

        try {
            Test.startTest();
            SlackNotificationRestService.sendMessageToSlack(TestConstants.TEST_NAME);
            Test.stopTest();

            Assert.fail();
        } catch (Exception e) {
            Assert.isTrue(e.getMessage() .contains('cannot be null'));
        }
    }

    @IsTest
    static void testBehavior() {
        TestDataFactory.createSlackConfiguration();
        HttpResponseGeneratorMock calloutMock = new HttpResponseGeneratorMock();
        Boolean isError = false;

        calloutMock.responses.addAll(
            TestMock.getMockCallouts(
                new List<TestMock.ResponseType>{
                    TestMock.ResponseType.TEST_REQUEST_200
                }
            )
        );

        Test.setMock(HttpCalloutMock.class, calloutMock);

        try {
            Test.startTest();
            SlackNotificationRestService.sendMessageToDigitalLeadSlack(TestConstants.TEST_NAME);
            Test.stopTest();
        } catch (Exception e) {
            isError = true;

        }

        Assert.isFalse(isError);
    }
}