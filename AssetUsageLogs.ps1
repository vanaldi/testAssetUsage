param([string] $tenantId, $appId, $appSecret, $dcrImmutableId, $dceEndpoint,  $resourceGroup, $resourceType,  $resourceName)
Add-Type -AssemblyName System.Web;
$scope= [System.Web.HttpUtility]::UrlEncode("https://monitor.azure.com//.default")   
$body = "client_id=$appId&scope=$scope&client_secret=$appSecret&grant_type=client_credentials";
$headers = @{"Content-Type"="application/x-www-form-urlencoded"};
$uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
Write-Output $uri
$bearerToken = (Invoke-RestMethod -Uri $uri -Method "Post" -Body $body -Headers $headers).access_token
$currentTime = Get-Date ([datetime]::UtcNow) -Format O
$staticData = @"
[
{
    "Time": "$currentTime",
    "ResourceGroup": "$resourceGroup",
    "ResourceName": "$resourceName",
    "ResourceType": "$resourceType"
}
]
"@;

$body = $staticData;
Write-Output $body
$headers = @{"Authorization"="Bearer $bearerToken";"Content-Type"="application/json"};
Write-Output $dceEndpoint
$uri = "$dceEndpoint/dataCollectionRules/$dcrImmutableId/streams/Custom-AssetUsage_CL?api-version=2021-11-01-preview"
Write-Output $uri
$uploadResponse = Invoke-RestMethod -Uri $uri -Method "Post" -Body $body -Headers $headers
