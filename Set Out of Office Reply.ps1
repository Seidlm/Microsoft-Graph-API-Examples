$clientID = "your Client ID"
$Clientsecret = "Your Secret"
$tenantID = "your Tenant"


$UPN = "jasmine.hofmeister@au2mator.com"

$HTMLintern=@"
<html>\n<body>\n<p>I'm at our company's worldwide reunion and will respond to your message as soon as I return.<br>\n</p></body>\n</html>\n
"@

$HTMLextern=@"
<html>\n<body>\n<p>I'm at the Contoso worldwide reunion and will respond to your message as soon as I return.<br>\n</p></body>\n</html>\n
"@


#Function



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



#Set MailboxSettings
$URLSETOOF = "https://graph.microsoft.com/v1.0/users/$UPN/mailboxSettings" 
#plan
$BodyJsonSETOOF = @"
            {
                
                "automaticRepliesSetting": {
                    "status": "Scheduled",
                    "scheduledStartDateTime": {
                      "dateTime": " 2020-08-25 12:00:00",
                      "timeZone": "UTC"
                    },
                    "scheduledEndDateTime": {
                      "dateTime": " 2021-08-25 12:00:00",
                      "timeZone": "UTC"
                    },
                    "internalReplyMessage": "$HTMLintern",
                    "externalReplyMessage": "$HTMLextern"
                }
            }
"@
#immediately
$BodyJsonSETOOF = @"
            {
                
                "automaticRepliesSetting": {
                    "status": "alwaysEnabled",
                    "internalReplyMessage": "$HTMLintern",
                    "externalReplyMessage": "$HTMLextern"
                }
            }
"@
    
$Result = Invoke-RestMethod -Headers $headers -Body $BodyJsonSETOOF -Uri $URLSETOOF -Method PATCH



