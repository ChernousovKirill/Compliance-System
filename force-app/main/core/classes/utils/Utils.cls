public with sharing class Utils {
    public static final String WWW_PREFIX_URL = 'www.';
    public static final String SLASH = '/';

    public String getCorrectLinkOfWebsite(String urlOfWebsite) {
        String urlOfWebsiteToLowerCase = urlOfWebsite.toLowerCase();

        Integer indexOfThreeW = urlOfWebsiteToLowerCase.indexOf(WWW_PREFIX_URL);
        String urlForSimilarWeb = '';

        if (indexOfThreeW != -1) {
            urlForSimilarWeb = urlOfWebsiteToLowerCase.substring(indexOfThreeW + 4);
        } else {
            urlForSimilarWeb = urlOfWebsiteToLowerCase;
        }

        if (urlForSimilarWeb.endsWith(SLASH)) {
            urlForSimilarWeb = urlForSimilarWeb.substring(0, urlForSimilarWeb.length() - 1);
        }

        return urlForSimilarWeb;
    }
}