@IsTest
public class HttpResponseGeneratorMock implements HttpCalloutMock {
    public List<ResponseTemplate> responses = new List<ResponseTemplate>();

    public HttpResponse respond(HttpRequest request) {
        ResponseTemplate responseTemplate = responses[0];
        responses.remove(0);

        HttpResponse response = new HttpResponse();

        response.setBody(responseTemplate.responseBody);
        response.setStatus(responseTemplate.status);
        response.setStatusCode(responseTemplate.statusCode);

        if (responseTemplate.headers != null || !responseTemplate.headers.isEmpty()) {
            for (String header : responseTemplate.headers.keySet()) {
                response.setHeader(header, responseTemplate.headers.get(header));
            }
        }

        return response;
    }

    public class ResponseTemplate {
        public Integer statusCode = 0;
        public String status = '';
        public String responseBody = '';
        public Map<String, String> headers = new Map<String, String>();

        public ResponseTemplate(Integer statusCode, String status, String responseBody, Map<String, String> headers) {
            this.statusCode = statusCode;
            this.status = status;
            this.responseBody = responseBody;
            this.headers = headers;
        }
    }
}