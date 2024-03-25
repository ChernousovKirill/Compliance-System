public with sharing class UserLicenseSelector {

    public static UserLicense getSalesforceUserLicense() {
        return [
            SELECT Name, TotalLicenses, UsedLicenses
            FROM UserLicense
            WHERE Name = :ConstantUtility.SALESFORCE_LICENSE
            LIMIT 1
        ];
    }
}