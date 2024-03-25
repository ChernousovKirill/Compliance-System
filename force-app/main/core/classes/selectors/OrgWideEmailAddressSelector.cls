public with sharing class OrgWideEmailAddressSelector {
    public static Id getNodaAddressId() {
        return [
            SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = :ConstantUtility.NODA_ADDRESS LIMIT 1
        ].Id;
    }

}