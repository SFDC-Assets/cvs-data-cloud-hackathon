@IsTest
public class UnifiedProfileController_Test {

    
	private static String token, iss, sub, aud, exp, key, token_endpoint, access_token;
    public static List<C360AuthSetting__mdt> getAllRecords() {
        return [ SELECT DeveloperName, MasterLabel, jwt_aud__c, jwt_exp__c, jwt_iss__c,jwt_sub__c, key__c, token_endpoint__c  
                	FROM C360AuthSetting__mdt 
                	WHERE MasterLabel = 'C360 Auth Settings'
                	LIMIT 1];
    }        
    
    public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            // Set the mock response based on the endpoint or other aspects of the request
            if(req.getEndpoint().contains('UnifiedLinkssotIndividualIr01__dlm') && req.getMethod() == 'GET') {
                res.setBody('{"data":[{"UnifiedRecordId__c":"2c1b2a8da0a7c6232f758c8a79eb3060","ssot__DataSourceObjectId__c":"Member","SourceRecordId__c":"0038a00003DRCV9AAP","ssot__DataSourceId__c":"Salesforce_00D8a000001LaO5"}]}');
                res.setStatusCode(200); // Simulate a successful response
            } else {
                //This is important becuase a token URL will be inviked and a mock token need to be generated.
                //else the test class will fail.
                if (req.getEndpoint().contains('token')) {
                    res.setBody('{"access_token":"mockAccessToken123"}');
                    res.setStatusCode(200);                    
                }else {
                	res.setBody('{"error":"Resource not found"}');
                	res.setStatusCode(500); // Simulate an error scenario                    
                }

            }
            return res;
        }
    }
    
    public class MockHttpResponseFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            // Set the mock response based on the endpoint or other aspects of the request
            if(req.getEndpoint().contains('UnifiedssotIndividualIr01__dlm') && req.getMethod() == 'GET') {
                res.setBody('{"data":[{"UnifiedRecordId__c":"2c1b2a8da0a7c6232f758c8a79eb3060","ssot__DataSourceObjectId__c":"Contact","SourceRecordId__c":"0038a00003DRCV9AAP","ssot__DataSourceId__c":"Salesforce_00D8a000001LaO5"}]}');
                res.setStatusCode(200); // Simulate a successful response
            } else {
                //This is important becuase a token URL will be inviked and a mock token need to be generated.
                //else the test class will fail.
                if (req.getEndpoint().contains('token')) {
                    res.setBody('{"access_token":"mockAccessToken123"}');
                    res.setStatusCode(200);                    
                }else {
                	res.setBody('{"error":"Resource not found"}');
                	res.setStatusCode(500); // Simulate an error scenario                    
                }

            }
            return res;
        }
    }    

    @isTest
    static void testGetUnifiedLinkDataSuccess() {

        Test.startTest();
		/*        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutToken());
        // Test constructor with DataSpaceName
        C360AuthController controllerWithDataSpace = new C360AuthController('MockDataSpace');
        System.assert(String.isNotEmpty(controllerWithDataSpace.dc_token), 'Token should not be empty');
		*/
        // Setup test data
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        // You will also need to mock C360AuthController and its response
        // Assuming dc_token is handled here
        String recordId = '0038a00003DRCV9AAP';
        String expectedToken = 'mockAccessToken123';

        //UnifiedProfileController.cdp_token = expectedToken;
        String result = UnifiedProfileController.getUnifiedProfile(recordId);
        System.debug(LoggingLevel.DEBUG, '>>> testGetUnifiedLinkDataSuccess - Start');
        System.debug(LoggingLevel.DEBUG, result);        
		System.debug(LoggingLevel.DEBUG, '>>> testGetUnifiedLinkDataSuccess - End');
        Test.stopTest();


        // Asserts to ensure the response was processed correctly
        System.assert(result.contains('2c1b2a8da0a7c6232f758c8a79eb3060'), 'Response should contain the unified record ID');
        System.assert(result.contains('cdp_DataSourceId'), 'Response should have transformed field names');
    }


    @isTest
    static void testGetUnifiedLinkDataFailure() {
        // Set up to simulate an HTTP 500 response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseFailure());
        String recordId = '0038a00003DRCV9AAP'; // Assuming this triggers the error in the mock
        String expectedToken = 'mockToken';


        Test.startTest();
        try {
            UnifiedProfileController.cdp_token = expectedToken;
            String result = UnifiedProfileController.getUnifiedProfile(recordId);
            System.debug(LoggingLevel.DEBUG, result);
            System.assert(false, 'Method should have thrown an exception');
        } catch (UnifiedProfileController.CustomException e) {
            // Assert to ensure the exception is handled properly
            System.assert(e.getMessage().contains('Resource not found'), 'Should handle HTTP 500 errors');
        }
        Test.stopTest();
    }

    
    
}