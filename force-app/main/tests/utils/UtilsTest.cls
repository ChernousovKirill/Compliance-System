@IsTest
private class UtilsTest {
    public static final String WWW_PREFIX_URL = 'www.';
    public static final String SLASH = '/';

    @isTest
    public static void getCorrectLinkOfWebsiteWithPrefix() {
        String webSite = TestConstants.TEST_SITE_URL;
        String webSiteUrl = WWW_PREFIX_URL + TestConstants.TEST_SITE_URL;

        String result = new Utils().getCorrectLinkOfWebsite(webSiteUrl);

        Assert.areEqual(webSite, result);
    }

    @isTest
    public static void getCorrectLinkOfWebsiteWithoutPrefix() {
        String webSite = TestConstants.TEST_SITE_URL;

        String result = new Utils().getCorrectLinkOfWebsite(webSite);

        Assert.areEqual(webSite, result);
    }

    @isTest
    public static void getCorrectLinkOfWebsiteWithPostfix() {
        String webSite = TestConstants.TEST_SITE_URL;
        String webSiteUrl = TestConstants.TEST_SITE_URL + SLASH;

        String result = new Utils().getCorrectLinkOfWebsite(webSiteUrl);

        Assert.areEqual(webSite, result);
    }

    @isTest
    public static void getCorrectLinkOfWebsiteWithPrefixPostfix() {
        String webSite = TestConstants.TEST_SITE_URL;
        String webSiteUrl = WWW_PREFIX_URL + TestConstants.TEST_SITE_URL + SLASH;

        String result = new Utils().getCorrectLinkOfWebsite(webSiteUrl);

        Assert.areEqual(webSite, result);
    }
}