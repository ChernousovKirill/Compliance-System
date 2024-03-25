public inherited sharing class TaskUtils {
    public static TaskBuilder taskBuilder = new TaskBuilder();

    public static Task createTask(Id whoId, String subject, Id ownerId, Date activityDate) {
        return taskBuilder.builder()
            .withWhoId(whoId)
            .withSubject(subject)
            .withOwnerId(ownerId)
            .withActivityDate(activityDate)
            .build(false);
    }
}