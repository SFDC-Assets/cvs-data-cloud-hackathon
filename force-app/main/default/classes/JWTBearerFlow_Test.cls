@IsTest
global class JWTBearerFlow_Test {

	private static String token, iss, sub, aud, exp, key, token_endpoint, access_token;
    public static List<C360AuthSetting__mdt> getAllRecords() {
        return [ SELECT DeveloperName, MasterLabel, jwt_aud__c, jwt_exp__c, jwt_iss__c,jwt_sub__c, key__c, token_endpoint__c  
                	FROM C360AuthSetting__mdt 
                	WHERE MasterLabel = 'C360 Auth Settings'
                	LIMIT 1];
    }        
    
	global class MockHttpResponseGenerator implements HttpCalloutMock {
    	global HTTPResponse respond(HTTPRequest req) {
        	// Create a fake response
	        HttpResponse res = new HttpResponse();
        	res.setHeader('Content-Type', 'application/json');
        	res.setBody('{"access_token": "MockAccessToken123456789"}');
        	res.setStatusCode(200);
        	return res;
    	}
	}
    
	global class MockHttpResponseGeneratorFailure implements HttpCalloutMock {
		global HttpResponse respond(HttpRequest request) {
        	HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"error": "invalid_request"}');
            response.setStatusCode(400);
            return response;
        }
	}    
    
    @isTest
    static void testGetAccessTokenSuccess() {
        
        //get the private key
        List<C360AuthSetting__mdt> eass =  getAllRecords();
        for(C360AuthSetting__mdt eas : eass ) {
            if(eas.MasterLabel.equals('C360 Auth Settings')) {
                iss = eas.jwt_iss__c;
                sub = eas.jwt_sub__c;
                aud = eas.jwt_aud__c;
                exp = eas.jwt_exp__c;
                key = eas.key__c;
                token_endpoint = eas.token_endpoint__c;
            }
        }
        System.debug(LoggingLevel.DEBUG, ' > getAccessToken - token_endpoint: ' + token_endpoint);

        String keyContents = key;
        keyContents = keyContents.replace('-----BEGIN RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('\n', '');        
        
        // Set up the JWT object
        JWT jwt = new JWT('RS256');
        jwt.iss = iss;
        jwt.sub = sub;
        jwt.aud = aud;
        jwt.exp = String.valueOf(DateTime.now().addHours(1).getTime());
        jwt.iat = String.valueOf(DateTime.now().getTime());
        jwt.pkcs8 = keyContents;  // Ensure this is set for JWT issuance
        // Set up the mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Test getAccessToken
        String tokenEndpoint = token_endpoint;
        String accessToken = JWTBearerFlow.getAccessToken(tokenEndpoint, jwt);
        System.assertEquals('MockAccessToken123456789', accessToken, 'Access token should match the mock response');
        
        String token = JWTBearerFlow.getAssertionValue(jwt);
        System.debug(token);
        System.assert(token != null, 'Access token cannot be null');
    }
    
    @isTest
    static void testGetAccessTokenFailure() {
        
        //get the private key
        List<C360AuthSetting__mdt> eass =  getAllRecords();
        for(C360AuthSetting__mdt eas : eass ) {
            if(eas.MasterLabel.equals('C360 Auth Settings')) {
                iss = eas.jwt_iss__c;
                sub = eas.jwt_sub__c;
                aud = eas.jwt_aud__c;
                exp = eas.jwt_exp__c;
                key = eas.key__c;
                token_endpoint = eas.token_endpoint__c;
            }
        }
        System.debug(LoggingLevel.DEBUG, ' > getAccessToken - token_endpoint: ' + token_endpoint);

        String keyContents = key;
        keyContents = keyContents.replace('-----BEGIN RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('\n', '');        
        
        // Set up the JWT object
        JWT jwt = new JWT('RS256');
        jwt.iss = iss;
        jwt.sub = sub;
        jwt.aud = aud;
        jwt.exp = String.valueOf(DateTime.now().addHours(1).getTime());
        jwt.iat = String.valueOf(DateTime.now().getTime());
        jwt.pkcs8 = keyContents;  // Ensure this is set for JWT issuance
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFailure());        
        // Test getAccessToken
        String tokenEndpoint = 'https://example.salesforce.com/services/oauth2/token';
        String accessToken = JWTBearerFlow.getAccessToken(tokenEndpoint, jwt);
        System.assert(accessToken == null, 'Access token should be null on failure');
    }
}