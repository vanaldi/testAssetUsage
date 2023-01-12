##################
### Step 0: Set parameters required for the rest of the script.
##################
#information needed to authenticate to AAD and obtain a bearer token
$tenantId = "72f988bf-86f1-41af-91ab-2d7cd011db47"; #Tenant ID the data collection endpoint resides in
$appId = "0bfd3e16-224e-4ec3-9b05-10aa61306118"; #Application ID created and granted permissions
$appSecret = "H6s8Q~whvXfaQrvAKbzYmr_v-GJNGohOXUcxqb_x"; #Secret created for the application

#information needed to send data to the DCR endpoint
$dcrImmutableId = "dcr-b445c63751704f2ea541d8f517acbade"; #the immutableId property of the DCR object
$dceEndpoint = "https://assetusageendpoint-3j0y.westus2-1.ingest.monitor.azure.com"; #the endpoint property of the Data Collection Endpoint object

##################
### Step 1: Obtain a bearer token used later to authenticate against the DCE.
##################
$scope= [System.Web.HttpUtility]::UrlEncode("https://monitor.azure.com//.default")   
$body = "client_id=$appId&scope=$scope&client_secret=$appSecret&grant_type=client_credentials";
$headers = @{"Content-Type"="application/x-www-form-urlencoded"};
$uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

$bearerToken = (Invoke-RestMethod -Uri $uri -Method "Post" -Body $body -Headers $headers).access_token

##################
### Step 2: Load up some sample data. 
##################
$currentTime = Get-Date ([datetime]::UtcNow) -Format O
$staticData = @"
[
{
    "Time": "$currentTime",
    "Computer": "Computer1",
    "AdditionalContext": {
                "InstanceName": "user3",
                "TimeZone": "Pacific Time",
                "Level": 4,
        "CounterName": "AppMetric1",
        "CounterValue": 15.3    
    }
},
{
    "Time": "$currentTime",
    "Computer": "Computer2",
    "AdditionalContext": {
                "InstanceName": "user4",
                "TimeZone": "Central Time",
                "Level": 3,
        "CounterName": "AppMetric1",
        "CounterValue": 23.5     
    }
}
]
"@;

##################
### Step 3: Send the data to Log Analytics via the DCE.
##################
$body = $staticData;
$headers = @{"Authorization"="Bearer $bearerToken";"Content-Type"="application/json"};
$uri = "$dceEndpoint/dataCollectionRules/$dcrImmutableId/streams/Custom-MyTableRawData?api-version=2021-11-01-preview"

$uploadResponse = Invoke-RestMethod -Uri $uri -Method "Post" -Body $body -Headers $headers