$clientID = "yourClientID"
$Clientsecret = "yourSecret"
$tenantID = "yourTenantID"

#Configure Device Properties
$UPN = "michael.seidl@au2mator.com"


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


#Get User ID
$URLGetUser = "https://graph.microsoft.com/v1.0/users/$UPN"
$USER = Invoke-RestMethod -Method GET -Uri $URLGetUser -Headers $headers


#Get Managed Device from User
$UriGetDevices = "https://graph.microsoft.com/v1.0/users/$($User.id)/managedDevices"
$Devices = (Invoke-RestMethod -Method GET -Uri $UriGetDevices -Headers $headers).value

if (@($Devices).count -gt 0) {
    foreach ($D in $Devices)
    {
        if ($D.operatingSystem -eq "iOS")
        {
            $URL="https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($d.id)/enableLostMode"

            $BodyJson = @"
            {
                "message": "Please Contact IT Support",
                "phoneNumber": "+43 1111 1111111",
                "footer": "Your IT"
            }
"@

Invoke-RestMethod -Uri $URL -Method POST -header $headers -body $BodyJson
        }
    }
}




#$URL="https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$($d.id)/disableLostMode"
#Invoke-RestMethod -Uri $URL -Method POST -header $authHeader


