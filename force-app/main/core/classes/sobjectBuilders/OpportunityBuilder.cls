public with sharing class OpportunityBuilder {
    private Opportunity opp = new Opportunity();

    public OpportunityBuilder builder() {
        return new OpportunityBuilder();
    }

    public OpportunityBuilder builder(Opportunity opp) {
        this.opp = opp;

        return this;
    }

    public Opportunity build(Boolean doInsert) {
        Opportunity newOpp = new Opportunity();

        if (this.opp.Id != null) {
            newOpp.Id = this.opp.Id;
        }
        if (this.opp.Name != null) {
            newOpp.Name = this.opp.Name;
        }
        if (this.opp.AccountId != null) {
            newOpp.AccountId = this.opp.AccountId;
        }
        if (this.opp.StageName != null) {
            newOpp.StageName = this.opp.StageName;
        }
        if (this.opp.CloseDate != null) {
            newOpp.CloseDate = this.opp.CloseDate;
        }
        if (this.opp.OwnerId != null) {
            newOpp.OwnerId = this.opp.OwnerId;
        }
        if (this.opp.RecordTypeId != null) {
            newOpp.RecordTypeId = this.opp.RecordTypeId;
        }
        if (this.opp.Service_Type__c != null) {
            newOpp.Service_Type__c = this.opp.Service_Type__c;
        }

        if (doInsert) {
            insert newOpp;
        }

        return newOpp;
    }

    public OpportunityBuilder withId(String id) {
        this.opp.Id = id;
        return this;
    }

    public OpportunityBuilder withName(String name) {
        this.opp.Name = name;
        return this;
    }

    public OpportunityBuilder withAccountId(Id accId) {
        this.opp.AccountId = accId;
        return this;
    }

    public OpportunityBuilder withStageName(String stage) {
        this.opp.StageName = stage;
        return this;
    }

    public OpportunityBuilder withCloseDate(Date closeDate) {
        this.opp.CloseDate = closeDate;
        return this;
    }

    public OpportunityBuilder withOwnerId(Id ownerId) {
        this.opp.OwnerId = ownerId;
        return this;
    }

    public OpportunityBuilder withRecordTypeId(Id recordTypeId) {
        this.opp.RecordTypeId = recordTypeId;
        return this;
    }

    public OpportunityBuilder withServiceType(String serviceType) {
        this.opp.Service_Type__c = serviceType;
        return this;
    }
}