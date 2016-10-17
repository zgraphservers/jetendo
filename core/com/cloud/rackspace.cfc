<cfcomponent interface="zcorerootmapping.interface.cloudVendor" extends="zcorerootmapping.com.cloud.cloudBase">
<cfoutput>
<cffunction name="login" localmode="modern" access="private">
	<cfscript>
	/*

	json={
		"auth":{
			"RAX-KSKEY:apiKeyCredentials":{
				"username":"yourUserName",
				"apiKey":"$apiKey"
			}
		}
	};
	link="https://identity.api.rackspacecloud.com/v2.0";
	// post json to link somehow
	<cfheader name="Content-type" value="application/json">
	 
	*/

	// token is valid for 24 hours or until revoked

	response={
        "access": {
                "token": {
                        "id": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
                        "expires": "2014-11-24T22:05:39.115Z",
                        "tenant": {
                                "id": "110011",
                                "name": "110011"
                        },
                        "RAX-AUTH:authenticatedBy": [
                                "APIKEY"
                        ]
                 },
                "serviceCatalog": [
                        {
                                "name": "cloudDatabases",
                                "endpoints": [
                                        {
                                        "publicURL": "https://syd.databases.api.rackspacecloud.com/v1.0/110011",
                                        "region": "SYD",
                                        "tenantId": "110011"
                                        },
                                        {
                                                "publicURL": "https://dfw.databases.api.rackspacecloud.com/v1.0/110011",
                                                "region": "DFW",
                                                "tenantId": "110011"
                                        },
                                        {
                                                "publicURL": "https://ord.databases.api.rackspacecloud.com/v1.0/110011",
                                                "region": "ORD",
                                                "tenantId": "110011"
                                        },
                                        {
                                                "publicURL": "https://iad.databases.api.rackspacecloud.com/v1.0/110011",
                                                "region": "IAD",
                                                "tenantId": "110011"
                                        },
                                        {
                                                "publicURL": "https://hkg.databases.api.rackspacecloud.com/v1.0/110011",
                                                "region": "HKG",
                                                "tenantId": "110011"
                                        }
                                ],
                                "type": "rax:database"
                        },
 

                        {
                                "name": "cloudDNS",
                                "endpoints": [
                                        {
                                                "publicURL": "https://dns.api.rackspacecloud.com/v1.0/110011",
                                                "tenantId": "110011"
                                        }
                                ],
                                "type": "rax:dns"
                        },
                        {
                                "name": "rackCDN",
                                "endpoints": [
                                        {
                                                "internalURL": "https://global.cdn.api.rackspacecloud.com/v1.0/110011",
                                                "publicURL": "https://global.cdn.api.rackspacecloud.com/v1.0/110011",
                                                "tenantId": "110011"
                                        }
                                ],

                                "type": "rax:cdn"
                        }
                ],
                "user": {
                        "id": "123456",
                        "roles": [
                                {
                                        "description": "A Role that allows a user access to keystone Service methods",
                                        "id": "6",
                                        "name": "compute:default",
                                        "tenantId": "110011"
                                },
                                {
                                        "description": "User Admin Role.",
                                        "id": "3",
                                        "name": "identity:user-admin"
                                }
                        ],
                        "name": "jsmith",
                        "RAX-AUTH:defaultRegion": "ORD"
                }
        }
}; 
</cfscript>
</cffunction>

<cffunction name="storeOnline" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript> 
	throw("not implemented");
	link="";
	/*
one container per site - 256 byte limit on name
	cloud-files-client.com

get login token: https://identity.api.rackspacecloud.com/v2.0
-X POST \
 -d '{"auth":{"RAX-KSKEY:apiKeyCredentials":{"username":"yourUserName","apiKey":"$apiKey"}}}' \
 -H "Content-type: application/json" | python -m json.tool
api calls:
account — for example, MossoCloudFS_0672d7fa-9f85-4a81-a3ab-adb66a880123
X-Auth-Token — for example, f064c46a782c444cb4ba4b6434288f7c
container — for example, MyContainer
object — for example, MyObject

	GET /v1/{account}/{container}/{object}

	*/
	return {success:true, cloud_file_url:link};
	</cfscript>
</cffunction>

<cffunction name="purgeFile" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	throw("not implemented");
	// issue real delete command to remote system
	//arguments.ds.cloud_file_url
	//arguments.ds.cloud_file_hash
	return true;
	</cfscript>
</cffunction>

<cffunction name="makeFileAvailableOffline" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	throw("not implemented");
	ds=arguments.ds;
	// download online to local path (force replace)
	newPath=ds.config.localPath&removeChars(fileData.cloud_file_local_path,1,1); 
	// allow 10 seconds per megabyte to download file
	seconds=round(10*(fileData.cloud_file_size/1024/1024));
	application.zcore.functions.zSetRequestTimeout(seconds+5); 

	application.zcore.functions.zHTTPToFile(fileData.cloud_file_url, newPath, seconds);
	if(not fileexists(newPath)){
		throw("Failed to download file: #fileData.cloud_file_url# for path: #arguments.path#");
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>