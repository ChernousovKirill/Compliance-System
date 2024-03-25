@RestResource(UrlMapping='/noda_webservice')
global without sharing class NodaHubRestService {

    @HttpGet
    global static void getNodaSettings() {
        RestRequest request = RestContext.request;

        if (HttpRequestService.validateRequestHeader(request.headers)) {
            return ;
        }

        try {
            Map<String, String> picklistValueByLabel = SobjectUtils.getSobjectPickListValues(
                request.params.get(ConstantUtility.OBJECT_NAME),
                request.params.get(ConstantUtility.FIELD_NAME)
            );
            RestResponse response = RestContext.response;
            if (picklistValueByLabel.isEmpty()) {
                response.statusCode = 404;
            } else {
                List<Map<String, String>> productsList = new List<Map<String, String>>();
                for (String productId : picklistValueByLabel.keySet()) {
                    Map<String, String> product = new Map<String, String>();
                    product.put('name', productId);
                    product.put('id', picklistValueByLabel.get(productId));
                    productsList.add(product);
                }
    
                response.statusCode = 200;
                response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                    ConstantUtility.SUCCESS => true,
                    ConstantUtility.PRODUCTS => productsList
                }));
            }
        } catch (Exception e) {
            throw new HandledException(e.getMessage());
        }
    }
}