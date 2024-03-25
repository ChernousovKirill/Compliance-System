public inherited sharing class LeadService {
    
    public static void asignDigitalLeadManagers (List<Lead> listOfDigitalLeads) {
        List<User> listOfSalesManagers = UserSelector.getDigitalLeadManagers();

        for(Lead lead : listOfDigitalLeads) {
            lead.OwnerId = listOfSalesManagers.get(0).Id;
        }
    }

    public static void sendEmailForManagers(List<Lead> listOfDigitalLeads) {
        String[] toAddresses = getUserAdresses();
        Id addressId = OrgWideEmailAddressSelector.getNodaAddressId();

        EmailService.sendEmails(listOfDigitalLeads, toAddresses, addressId, Label.newDigitalLeadSubject);

    }

    public static void createCallTask(List<Lead> listOfDigitalLeads) {
        List<Task> listOfTasks = new List<Task>();
        Date activityDate = getActivityDate();

        for(Lead lead : listOfDigitalLeads) {
            listOfTasks.add(TaskUtils.createTask(lead.Id, 'Call', lead.OwnerId, activityDate));
        }
        insert listOfTasks;
    }

    private static String[] getUserAdresses() {

        String[] toAddresses = new String[]{};
        List<User> listOfSupervisors = UserSelector.getUserByProfile(ConstantUtility.SUPERVISOR);
        if(!listOfSupervisors.isEmpty()) {
            for(User user : listOfSupervisors) {
                toAddresses.add(user.Email);
            }
        }
        if (!toAddresses.isEmpty()) {
            return toAddresses;
        }
        return null;

    }

    private static Date getActivityDate() {
        Date activityDate;

        Date today = Date.today();
        Datetime dateTimeToday = (DateTime)today;
        String dayOfWeek = dateTimeToday.format('EEEE');

        if (dayOfWeek == 'Saturday') {
            activityDate = today.addDays(2);
        } else if (dayOfWeek == 'Sunday') {
            activityDate = today.addDays(1);
        } else {
            activityDate = today;
        }
        
        return activityDate;
    }
}