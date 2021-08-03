$clientID = "your ID"
$Clientsecret = "your Secret"
$tenantID = "tenant ID"

$UPN = "michael.seidl@au2mator.com"
$License = "Windows 365 Business 4 vCPU, 16 GB, 128 GB (with Windows Hybrid Benefit)"


#Function
Function GET-SKUId {
   
    Param (
        [string]$Name,
        [string]$Searchcoloumn,
        [string]$resultcoloumn
    )
    $data = @(
        [pscustomobject]@{ProductName = 'POWER BI (FREE)'; SKUID = 'a403ebcc-fae0-4ca2-8c8c-7a907fd6c235' }
        [pscustomobject]@{ProductName = 'POWER BI PRO'; SKUID = 'f8a1db68-be16-40ed-86d5-cb42ce701560' }
        [pscustomobject]@{ProductName = 'EXCHANGE ONLINE (PLAN 1)'; SKUID = '4b9405b0-7788-4568-add1-99614e613b69' }
        [pscustomobject]@{ProductName = 'EXCHANGE ONLINE (PLAN 2)'; SKUID = '19ec0d23-8335-4cbd-94ac-6050e30712fa' }
        [pscustomobject]@{ProductName = 'ONEDRIVE FOR BUSINESS (PLAN 1)'; SKUID = 'e6778190-713e-4e4f-9119-8b8238de25df' }
        [pscustomobject]@{ProductName = 'ONEDRIVE FOR BUSINESS (PLAN 2)'; SKUID = 'ed01faf2-1d88-4947-ae91-45ca18703a96' }
        [pscustomobject]@{ProductName = 'PROJECT PLAN 1'; SKUID = 'beb6439c-caad-48d3-bf46-0c82871e12be' }
        [pscustomobject]@{ProductName = 'Microsoft StaffHub'; SKUID = '8c7d2df8-86f0-4902-b2ed-a0458298f3b3' }
        [pscustomobject]@{ProductName = 'Windows 365 Business 4 vCPU, 16 GB, 128 GB (with Windows Hybrid Benefit)'; SKUID = '439ac253-bfbc-49c7-acc0-6b951407b5ef' }
        
    )
 
    $result = $data | Where-Object { $_.$Searchcoloumn -eq $Name } | Select-Object -Property $resultcoloumn
    return $result[0].$resultcoloumn
 
}

#Connect to GRAPH API
$tokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientId
    Client_Secret = $clientSecret
}
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method POST -Body $tokenBody
$headers = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type"  = "application/json"
}


#Get SKU ID from Function
$SKUID = GET-SKUId -Name "$License" -Searchcoloumn "ProductName" -resultcoloumn "SKUID"

#Assign License
$URLtoassignLicense = "https://graph.microsoft.com/v1.0/users/$UPN/assignLicense" 
$BodyJsontoassignLicense = @"
            {
                "addLicenses":[
                      {
                        "disabledPlans": [ ],
                        "skuId": " $SKUID"
                      }
                   ],
                   "removeLicenses": []
            }
"@
    
$Result = Invoke-RestMethod -Headers $headers -Body $BodyJsontoassignLicense -Uri $URLtoassignLicense -Method POST



