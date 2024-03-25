public with sharing class TaskBuilder {
    private Task task = new Task();

    public TaskBuilder builder() {
        return new TaskBuilder();
    }

    public TaskBuilder builder(Task task) {
        this.task = task;

        return this;
    }

    public Task build(Boolean doInsert) {
        Task newTask = new Task();

        if (this.task.WhoId != null) {
            newTask.WhoId = this.task.WhoId;
        }
        if (this.task.Subject != null) {
            newTask.Subject = this.task.Subject;
        }
        if (this.task.OwnerId != null) {
            newTask.OwnerId = this.task.OwnerId;
        }
        if (this.task.ActivityDate != null) {
            newTask.ActivityDate = this.task.ActivityDate;
        }

        if (doInsert) {
            insert newTask;
        }

        return newTask;
    }

    public TaskBuilder withWhoId(Id whoId) {
        this.task.WhoId = whoId;
        return this;
    }

    public TaskBuilder withSubject(String subject) {
        this.task.Subject = subject;
        return this;
    }

    public TaskBuilder withOwnerId(Id ownerId) {
        this.task.OwnerId = ownerId;
        return this;
    }

    public TaskBuilder withActivityDate(Date activityDate) {
        this.task.ActivityDate = activityDate;
        return this;
    }

}