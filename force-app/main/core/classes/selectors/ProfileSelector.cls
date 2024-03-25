public with sharing class ProfileSelector {
    public static List<Profile> getProfileByIds(Set<Id> profileIds) {
        return [SELECT Profile.Name FROM Profile WHERE Id IN :profileIds];
    }
}