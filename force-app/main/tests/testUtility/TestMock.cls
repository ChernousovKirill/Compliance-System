@IsTest
public class TestMock {
    public static Integer STATUS_CODE_200 = 200;
    public static Integer STATUS_CODE_400 = 400;

    public static Map<String, String> EMPTY_HEADERS = new Map<String, String>();

    public static String END_POINT_DEFAULT = 'test.endpoint';
    public static String STATUS_OK = 'OK';
    public static String STATUS_BAD_REQUEST = 'Bad Request';
    public static String RESPONSE_BODY = '';
    public static String RESPONSE_BODY_EMPTY = '';
    public static String RESPONSE_BODY_SLACK_200 = '{"ok":true,"channel":"tmp","ts":"1705","message":{"bot_id":"123","type":"message","text":"This is a line of text"}}';
    public static String RESPONSE_BODY_SLACK_200_WITH_ERROR = '{"ok":true,"error":"This is a line of text"}}';
    public static String RESPONSE_BODY_SLACK_400 = '{"text":"This is a line of text"}';


    public static List<HttpResponseGeneratorMock.ResponseTemplate> getMockCallouts(List<ResponseType> responseTypes) {
        List<HttpResponseGeneratorMock.ResponseTemplate> result = new List<HttpResponseGeneratorMock.ResponseTemplate>();

        for (ResponseType respType : responseTypes) {
            switch on respType {
                when SEND_SLACK_MESSAGE_200 {
                    result.add(
                        new HttpResponseGeneratorMock.ResponseTemplate(
                            TestMock.STATUS_CODE_200,
                            TestMock.STATUS_OK,
                            'sendMessageToSlack',
                            TestMock.EMPTY_HEADERS
                        )
                    );
                }
                when SEND_SLACK_MESSAGE_400 {
                    result.add(
                        new HttpResponseGeneratorMock.ResponseTemplate(
                            TestMock.STATUS_CODE_400,
                            TestMock.STATUS_BAD_REQUEST,
                            'sendMessageToSlack',
                            TestMock.EMPTY_HEADERS
                        )
                    );
                }
                when TEST_REQUEST_200 {
                    result.add(
                        new HttpResponseGeneratorMock.ResponseTemplate(
                            TestMock.STATUS_CODE_200,
                            TestMock.STATUS_OK,
                            RESPONSE_BODY_SLACK_200,
                            TestMock.EMPTY_HEADERS
                        )
                    );
                }
                when TEST_REQUEST_200_WITH_ERROR {
                    result.add(
                        new HttpResponseGeneratorMock.ResponseTemplate(
                            TestMock.STATUS_CODE_200,
                            TestMock.STATUS_OK,
                            RESPONSE_BODY_SLACK_200_WITH_ERROR,
                            TestMock.EMPTY_HEADERS
                        )
                    );
                }
                when TEST_REQUEST_400 {
                    result.add(
                        new HttpResponseGeneratorMock.ResponseTemplate(
                            TestMock.STATUS_CODE_400,
                            TestMock.STATUS_BAD_REQUEST,
                            RESPONSE_BODY_SLACK_400,
                            TestMock.EMPTY_HEADERS
                        )
                    );
                }
            }
        }

        return result;
    }

    public enum ResponseType {
        SEND_SLACK_MESSAGE_200,
        SEND_SLACK_MESSAGE_400,
        TEST_REQUEST_200,
        TEST_REQUEST_200_WITH_ERROR,
        TEST_REQUEST_400
    }
}