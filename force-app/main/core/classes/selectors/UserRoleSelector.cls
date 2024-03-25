public with sharing class UserRoleSelector {
    public static List<UserRole> getUserRoleByIds(Set<Id> roleIds) {
        return [SELECT UserRole.Name FROM UserRole WHERE Id IN :roleIds];
    }
}