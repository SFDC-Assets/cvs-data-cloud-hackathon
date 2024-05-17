# CVS Hackathon team - Welcome to your journey to hack and learn salesforce data cloud and AI
## Steps to develop Apex controller and LWC
- Data cloud being near core you will always need a JWT token for Authorizarion as part of the Bearer payload for all GET and POST
 - Apex class dependency, they are already coded and ready to be used for generating the JWT token.
    1. JWT
    2. JWTBearerFlow
    3. C360AuthController
### NOTE: Please move the URL and ENTITY_NAME to configuration element like custom settings or custom metadata types to make it more dry.
### Below code snippet will help you get the cdp_token for all your request.
### APEX Controller class - UnifiedProfileController
### LWC - unifiedProfileView
```
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

```

```
//Sample Usage
            String finalURL = URL + '/api/v1/profile' + '/' + ENTITY_NAME + '?' + fields + '&' + limitCriteria + '&' + filters;
            System.debug(LoggingLevel.DEBUG, finalURL);
	        Http h = new Http();
        	HttpRequest req = new HttpRequest();
	        req.setMethod('GET');
        	req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        	req.setHeader('Authorization', 'Bearer ' + cdp_token);
			req.setEndpoint(finalURL);
```
- ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) `IMPORTANT`
```diff
- ### NOTE 
- For security reasons the attributes responsible for JWT token genration is not checked in but it exists in the org which should work seamlessly.
- ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png)
# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
