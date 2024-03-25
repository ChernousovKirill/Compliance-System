public with sharing class OpportunityUtils {
    public static OpportunityBuilder oppBuilder = new OpportunityBuilder();

    public static Opportunity createOpportunity(String name, Id accountId, Id ownerId, String stage, Date closeDate, Id recordTypeId, String serviceType) {
        return oppBuilder.builder()
            .withName(name)
            .withAccountId(accountId)
            .withOwnerId(ownerId)
            .withStageName(stage)
            .withCloseDate(closeDate)
            .withRecordTypeId(recordTypeId)
            .withServiceType(serviceType)
            .build(false);
    }

    public Opportunity updateOpportunityOwner(Opportunity opportunity, Id acccountOwnerId) {
        opportunity.OwnerId = acccountOwnerId;
        return opportunity;
    }

}