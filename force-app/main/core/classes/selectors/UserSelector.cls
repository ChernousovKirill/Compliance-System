public without sharing class UserSelector {
    public static List<User> getUserByIds(Set<Id> ids) {
        return [SELECT Id, Profile.Name, UserRole.Name, Username FROM User WHERE Id IN :ids];
    }

    public static List<User> getDigitalLeadManagers() {
        return [
                SELECT Id, Name, Email 
                FROM User 
                WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = :ConstantUtility.DIGITAL_LEAD_GROUP)
            ];
    }

    public static List<User> getUserByProfile(String profileName) {
        return [SELECT Id, Email, Profile.Name, IsActive
                FROM User 
                WHERE Profile.Name = :profileName
                AND IsActive = TRUE
            ];
    }
}