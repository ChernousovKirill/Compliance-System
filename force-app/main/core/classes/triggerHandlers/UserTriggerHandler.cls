public with sharing class UserTriggerHandler extends TriggerHandler {
    private static final String CURRENT_USER_NAME = UserInfo.getUserName();
    private static Map<Id, List<String>> newUserMessagesByUserId = new Map<Id, List<String>>();
       
    public override void afterInsert() {
        List<User> newUsers = UserSelector.getUserByIds(Trigger.newMap.keySet());
        List<String> newUserMessages = new List<String>();

        for (User newUser : newUsers) {
            newUserMessages.add(String.format(Label.newUserMessageTemplate, new List<Object>{
                CURRENT_USER_NAME, newUser.Username, newUser.Profile.Name, newUser.UserRole.Name
            }));
        }

        sendMessageToSlack(String.join(newUserMessages, '\n'));
    }

    public override void afterUpdate() {
        Map<Id, User> newUsers = (Map<Id, User>) Trigger.newMap;
        Map<Id, User> oldUsers = (Map<Id, User>) Trigger.oldMap;

        Set<Id> changedRoleIds = new Set<Id>();
        Set<Id> changedProfileIds = new Set<Id>();
        Set<User> changedUsers = new Set<User>();

        for (User user : newUsers.values()) {
            if (user.UserRoleId != oldUsers.get(user.Id).UserRoleId) {
                changedRoleIds.add(user.UserRoleId);
                changedRoleIds.add(oldUsers.get(user.Id).UserRoleId);
                changedUsers.add(user);
            }

            if (user.ProfileId != oldUsers.get(user.Id).ProfileId) {
                changedProfileIds.add(user.ProfileId);
                changedProfileIds.add(oldUsers.get(user.Id).ProfileId);
                changedUsers.add(user);
            }

            if (user.IsActive != oldUsers.get(user.Id).IsActive) {
                addChangedValues(
                    user,
                    String.valueOf(user.IsActive),
                    String.valueOf(oldUsers.get(user.Id).IsActive),
                    Label.updateUserIsActiveValue
                );
            }
        }
        makeNotificationMessages(changedRoleIds, changedProfileIds, changedUsers, oldUsers);
        sendMessage();
    }

    private static void makeNotificationMessages(Set<Id> changedRoleIds, Set<Id> changedProfileIds, Set<User> changedUsers, Map<Id, User> oldUsers) {
        Map<Id, Profile> profileByIds = new Map<Id, Profile>(ProfileSelector.getProfileByIds(changedProfileIds));
        Map<Id, UserRole> userRoleByIds = new Map<Id, UserRole>(UserRoleSelector.getUserRoleByIds(changedRoleIds));

        for (User changedUser : changedUsers) {
            if (changedUser.ProfileId != oldUsers.get(changedUser.Id).ProfileId) {
                addChangedValues(
                    changedUser,
                    profileByIds.get(changedUser.ProfileId).Name,
                    profileByIds.get(oldUsers.get(changedUser.Id).ProfileId).Name,
                    Label.updateUserProfileValue
                );
            }

            if (changedUser.UserRoleId != oldUsers.get(changedUser.Id).UserRoleId) {
                addChangedValues(
                    changedUser,
                    getRoleValue(userRoleByIds.get(changedUser.UserRoleId)),
                    getRoleValue(userRoleByIds.get(oldUsers.get(changedUser.Id).UserRoleId)),
                    Label.updateUserRoleValue
                );
            }
        }
    }

    private static String getRoleValue(UserRole userRole) {
       return userRole == null ? '' : userRole.Name;
    }

    private static void addChangedValues(User user, String newValue, String oldValue, String messageTemplate) {
        if (!newUserMessagesByUserId.containsKey(user.Id)) {
            newUserMessagesByUserId.put(
                user.Id, new List<String>{
                    String.format(Label.updateUserMessageTemplate, new List<Object>{
                        user.Username, CURRENT_USER_NAME
                    })
                });
        }

        newUserMessagesByUserId.get(user.Id).add(String.format(messageTemplate, new List<Object>{
            oldValue, newValue
        }));
    }

    private static void sendMessage() {
        if (newUserMessagesByUserId.values().isEmpty()) {
            return ;
        }

        List<String> newUserMessages = new List<String>();

        for (List<String> messages : newUserMessagesByUserId.values()) {
            newUserMessages.add(String.join(messages, '\n'));
        }

        sendMessageToSlack(String.join(newUserMessages, '\n'));
    }

    private static String countAvailableSalesfoceLicense() {

        UserLicense salesforceLicense = UserLicenseSelector.getSalesforceUserLicense();
        Integer amountOfAvailableLicense = salesforceLicense.TotalLicenses - salesforceLicense.UsedLicenses;

        return String.valueOf(amountOfAvailableLicense);
    }

    @Future(Callout=true)
    private static void sendMessageToSlack(String message) {

        String amountOfAvailableLicense = countAvailableSalesfoceLicense();
        String messageForSlack = message + ' ' + Label.updateSalesforceLicenseAmount + ' ' + amountOfAvailableLicense;

        SlackNotificationRestService.sendMessageToSlack(messageForSlack) ;
    }
}