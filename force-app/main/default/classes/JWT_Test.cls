@isTest
public class JWT_Test {
	private static String token, iss, sub, aud, exp, key, token_endpoint, access_token;
    public static List<C360AuthSetting__mdt> getAllRecords() {
        return [ SELECT DeveloperName, MasterLabel, jwt_aud__c, jwt_exp__c, jwt_iss__c,jwt_sub__c, key__c, token_endpoint__c  
                	FROM C360AuthSetting__mdt 
                	WHERE MasterLabel = 'C360 Auth Settings'
                	LIMIT 1];
    }    
    
    @isTest
    public static void testHS256() {
        JWT tokenGenerator = new JWT(JWT.HS256);
        tokenGenerator.iss = 'issuer';
        tokenGenerator.sub = 'subject';
        tokenGenerator.aud = 'audience';
        tokenGenerator.privateKey = EncodingUtil.base64Encode(Blob.valueOf('secret'));


        String jwt = tokenGenerator.issue();
        System.assertNotEquals(null, jwt, 'JWT should not be null');
        System.assert(jwt.contains('.'), 'JWT should contain periods indicating sections.');
    }

    @isTest
    public static void testRS256WithPrivateKey() {
        
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
        
        JWT tokenGenerator = new JWT('RS256');
        tokenGenerator.iss = iss;
        tokenGenerator.sub = sub;
        tokenGenerator.aud = aud;
        tokenGenerator.exp = exp;
        //tokenGenerator.pkcs8 = EncodingUtil.base64Encode(Blob.valueOf(keyContents));
        tokenGenerator.pkcs8 = keyContents;


        String jwt = tokenGenerator.issue();
        System.assertNotEquals(null, jwt, 'JWT should not be null');
        System.assert(jwt.contains('.'), 'JWT should contain periods indicating sections.');
    }
    
    @isTest
    public static void testNoneAlgorithm() {
        JWT tokenGenerator = new JWT(JWT.NONE);
        tokenGenerator.iss = 'issuer';
        tokenGenerator.sub = 'subject';
        tokenGenerator.aud = 'audience';


        String jwt = tokenGenerator.issue();
        System.assertNotEquals(null, jwt, 'JWT should not be null');
        System.assert(jwt.endsWith('.'), 'JWT with no algorithm should end with a period.');
    }
    
    @isTest
    public static void testClaimHandling() {
        JWT tokenGenerator = new JWT(JWT.HS256);
        tokenGenerator.iss = 'issuer';
        tokenGenerator.sub = 'subject';
        tokenGenerator.aud = 'audience';
        tokenGenerator.privateKey = EncodingUtil.base64Encode(Blob.valueOf('secret'));
        tokenGenerator.claims = new Map<String, String>{
            'email' => 'example@example.com',
            'role' => 'admin'
        };


        String jwt = tokenGenerator.issue();
        System.assertNotEquals(null, jwt, 'JWT should not be null');
        System.assert(jwt.contains('.'), 'JWT should contain periods indicating sections.');
    }


    @isTest
    public static void testExpirationHandling() {
        JWT tokenGenerator = new JWT(JWT.HS256);
        tokenGenerator.iss = 'issuer';
        tokenGenerator.sub = 'subject';
        tokenGenerator.aud = 'audience';
        tokenGenerator.validFor = 600; // 10 minutes
        tokenGenerator.privateKey = EncodingUtil.base64Encode(Blob.valueOf('secret'));


        String jwt = tokenGenerator.issue();
        System.assertNotEquals(null, jwt, 'JWT should not be null');
        System.assert(jwt.contains('.'), 'JWT should contain periods indicating sections.');
    }
}