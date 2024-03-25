@isTest
private class LoggerUtilTest {
    
    @isTest
    static void testErrorMethod() {
        LoggerUtil.error('Test error message');
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        LoggerUtil.error('Test error message with recordId', testAccount.Id);
        
        try {
            Integer a = 1 / 0;
        } catch (Exception e) {
            LoggerUtil.error('Test error message with exception', e);
        }
        
        try {
            Integer a = 1 / 0;
        } catch (Exception e) {
            LoggerUtil.error('Test error message with recordId and exception', testAccount.Id, e);
        }
    }
    
    @isTest
    static void testErrorWithSaveMethod() {
        try {
            Integer a = 1 / 0; 
        } catch (Exception e) {
            LoggerUtil.error('Test error message with saving log', e, true);
        }
    }
    
    @isTest
    static void testSaveLogMethod() {
        LoggerUtil.saveLog();
    }
    
    @isTest
    static void testErrorLwcMethod() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        LoggerUtil.errorLwc('Test error message from LWC', testAccount.Id);
    }
}
