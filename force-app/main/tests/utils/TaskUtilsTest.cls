@IsTest
private class TaskUtilsTest {
    @IsTest
    static void createTask() {

        Task task = new TaskBuilder()
            .withWhoId(UserInfo.getUserId())
            .withSubject(TestConstants.TEST_NAME)
            .withOwnerId(UserInfo.getUserId())
            .withActivityDate(Date.today())
            .build(false);

        Assert.areEqual(TestConstants.TEST_NAME, task.Subject);
        Assert.areEqual(UserInfo.getUserId(), task.WhoId);
        Assert.areEqual(UserInfo.getUserId(), task.OwnerId);
        Assert.areEqual(Date.today(), task.ActivityDate);
    }
}