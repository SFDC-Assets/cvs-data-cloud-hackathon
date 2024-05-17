@isTest
public class C360AuthController_Test {

    public class MockHttpCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
                if (req.getEndpoint().contains('token')) {
                    res.setBody('{"access_token":"mockAccessToken123"}');
                    res.setStatusCode(200);
                } else {
                    res.setStatusCode(500);
                    res.setBody('{"error":"mock error"}');
                }
            return res;
        }    
    }    
    
    public class MockHttpCalloutFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
                if (req.getEndpoint().contains('token')) {
                    res.setBody('{"access_token":""}');
                    res.setStatusCode(200);
                } else {
                    res.setStatusCode(500);
                    res.setBody('{"error":"mock error"}');
                }
            return res;
        }    
    }    
    
	private static String token, iss, sub, aud, exp, key, token_endpoint, access_token;
    public static List<C360AuthSetting__mdt> getAllRecords() {
        return [ SELECT DeveloperName, MasterLabel, jwt_aud__c, jwt_exp__c, jwt_iss__c,jwt_sub__c, key__c, token_endpoint__c  
                	FROM C360AuthSetting__mdt 
                	WHERE MasterLabel = 'C360 Auth Settings'
                	LIMIT 1];
    }        
    


    static testMethod void testController() {
        // Set up Mock HttpResponse
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
        // Test constructor with DataSpaceName
        C360AuthController controllerWithDataSpace = new C360AuthController('MockDataSpace');
        System.assert(String.isNotEmpty(controllerWithDataSpace.dc_token), 'Token should not be empty');
    }
    
	static testMethod void testGetAccessToken() {
        

        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());

        // Test getAccessToken
        C360AuthController controller = new C360AuthController();
        String accessToken = controller.getAccessToken();
        System.assert(String.isNotEmpty(accessToken), 'Access token should not be empty');

        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutFailure());
        C360AuthController failedController = new C360AuthController('Fail');
        String failedAccessToken = failedController.getAccessToken();
        System.debug(LoggingLevel.DEBUG, failedAccessToken);
        System.assert(String.isEmpty(failedAccessToken), 'Failed access token should be empty');
    }
    


}