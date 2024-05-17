public class UnifiedProfileController {
    
    public class CustomException extends Exception {} 
    public static String cdp_token {get; set;}
    // The below 2 variables will changed based on new DC environment.
    public static String URL = 'https://gnrtgnlbmm2dmnbrgvstkyldgu.c360a.salesforce.com';
    public static String ENTITY_NAME = 'UnifiedLinkssotIndividualIr01__dlm';

    public static String getCDPToken() {
        C360AuthController cdpAuth = new C360AuthController('default');  
        cdp_token = cdpAuth.dc_token;
        return cdp_token;        
    } 
    
    @AuraEnabled
	public static String getUnifiedProfile(String recordId) {
        System.debug(LoggingLevel.DEBUG, '>>> crm record id ' + recordId);
		cdp_token = getCDPToken();
        String payload = getUnifiedLinkData(cdp_token, recordId);
		String result = getUniversalIdLookUp(cdp_token, payload);
        return payload;
    }
    
    private static string getUnifiedLinkData(String cdp_token, String recordId) {
        String result = '';
        try{
            String fields = 'fields=SourceRecordId__c,UnifiedRecordId__c,ssot__DataSourceId__c,ssot__DataSourceObjectId__c';
            String limitCriteria = 'limit=10';
            String filters = 'filters=[SourceRecordId__c=' + recordId + ']';
            String finalURL = URL + '/api/v1/profile' + '/' + ENTITY_NAME + '?' + fields + '&' + limitCriteria + '&' + filters;
            System.debug(LoggingLevel.DEBUG, finalURL);
	        Http h = new Http();
        	HttpRequest req = new HttpRequest();
	        req.setMethod('GET');
        	req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        	req.setHeader('Authorization', 'Bearer ' + cdp_token);
			req.setEndpoint(finalURL);
        	HttpResponse res = h.send(req);
        	System.debug(LoggingLevel.DEBUG, '>>> raw output ' + res.getBody());  
        	System.debug(LoggingLevel.DEBUG, '>>> status code ' + res.getStatusCode());  
        	if(res.getStatusCode() == 500) {
            	System.debug(LoggingLevel.ERROR, '>>> error ' + res.getStatus());  
            	throw new CustomException(res.getBody());
        	}
        	Boolean errorFlag = false;
            String tempData1 = res.getBody().replaceAll('__c','');
            String tempData2 = tempData1.replaceAll('ssot__', 'cdp_');
            String tempData3 = tempData2.replaceAll('metadata', 'cdp_metadata');            
            result = tempData2;            
            System.debug(LoggingLevel.DEBUG, '>>> Step 1 getUnifiedLinkData - Start');
            System.debug(LoggingLevel.DEBUG, result);
            System.debug(LoggingLevel.DEBUG, '>>> Step 1 getUnifiedLinkData - End');
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            throw new CustomException(ex.getMessage());
        }
        return result;
    }
    
    private static String getUniversalIdLookUp(String cdp_token, String payload) {
        String result = '';
        String entityName, dataSourceId, dataSourceObjectId, sourceRecordId;
        //Step 1: parse the payload
        List<UnifiedData> records = parseJson(payload);
        for(UnifiedData record : records) {
			entityName = ENTITY_NAME;
            dataSourceId = record.cdp_DataSourceId;
			dataSourceObjectId = renameDataSourceObjectId(record.cdp_DataSourceObjectId);
            sourceRecordId = record.SourceRecordId;
        }
        //Step 2: Construct the URL
		String finalURL = URL + '/api/v1/universalIdLookup/' + entityName + '/' + dataSourceId + '/' + dataSourceObjectId + '/' + sourceRecordId;
        System.debug(LoggingLevel.DEBUG, finalURL);
        //Step 3: Invoke the URL
        try{
        //Step 4: Get the payload
	        Http h = new Http();
        	HttpRequest req = new HttpRequest();
	        req.setMethod('GET');
        	req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        	req.setHeader('Authorization', 'Bearer ' + cdp_token);
			req.setEndpoint(finalURL);
        	HttpResponse res = h.send(req);
        	System.debug(LoggingLevel.DEBUG, '>>> raw output ' + res.getBody());  
        	System.debug(LoggingLevel.DEBUG, '>>> status code ' + res.getStatusCode());  
        	if(res.getStatusCode() == 500) {
            	System.debug(LoggingLevel.ERROR, '>>> error ' + res.getStatus());  
            	throw new CustomException(res.getBody());
        	}
        	Boolean errorFlag = false;
            String tempData1 = res.getBody().replaceAll('__c','');
            String tempData2 = tempData1.replaceAll('ssot__', 'cdp_');
            String tempData3 = tempData2.replaceAll('metadata', 'cdp_metadata');            
            result = tempData2;            
            System.debug(LoggingLevel.DEBUG, '>>> Step 1 getUnifiedLinkData - Start');
            System.debug(LoggingLevel.DEBUG, result);
            System.debug(LoggingLevel.DEBUG, '>>> Step 1 getUnifiedLinkData - End');
        }catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
        }
        //Step 5: Parse the data
        return result;
    }
    
    public class RootObject {
        public List<UnifiedData> data;
    }
    public class UnifiedData {
        public String UnifiedRecordId;
        public String cdp_DataSourceObjectId;
        public String SourceRecordId;
        public String cdp_DataSourceId;
    }
    public static List<UnifiedData> parseJson(String jsonString) {
        List<UnifiedData> records = new List<UnifiedData>();
        RootObject root = (RootObject) JSON.deserialize(jsonString, RootObject.class);
        for (UnifiedData item : root.data) {
            System.debug('UnifiedRecordId: ' + item.UnifiedRecordId);
            System.debug('cdp_DataSourceObjectId: ' + item.cdp_DataSourceObjectId);
            System.debug('SourceRecordId: ' + item.SourceRecordId);
            System.debug('cdp_DataSourceId: ' + item.cdp_DataSourceId);
            records.add(item);
        }
        return records;
    }
    
    private static String renameDataSourceObjectId(String objectLabel) {
        String result = '';
        if(objectLabel.equals('Member')){
            result = objectLabel + '__c';
        }
        return result;
        
    }
    
    
}