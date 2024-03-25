public with sharing class LoggerUtil {
    public static void error(String logMessage) {
        Nebula.Logger.error(logMessage);
    }

    public static void error(String logMessage, Id recordId) {
        Nebula.Logger.error(logMessage, recordId);
    }

    public static void error(String logMessage, Exception apexException) {
        Nebula.Logger.error(logMessage, apexException);
    }

    public static void error(String logMessage, Id recordId, Exception apexException) {
        Nebula.Logger.error(logMessage, recordId, apexException);
    }

    public static void error(String logMessage, Exception apexException, Boolean isSave) {
        Nebula.Logger.error(logMessage, apexException);

        if (isSave) {
            saveLog();
        }
    }

    public static void saveLog() {
        Nebula.Logger.saveLog();
    }

    @AuraEnabled
    public static void errorLwc(String logMessage, Id recordId) {
        error(logMessage, recordId);
        saveLog();
    }
}