$clientID = "yourClientID"
$Clientsecret = "yourSecret"
$tenantID = "yourTenantID"

$MailSender = "michael.seidl@au2mator.com"

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

#Send Mail    
$URLsend = "https://graph.microsoft.com/v1.0/users/$MailSender/sendMail"
$BodyJsonsend = @"
                    {
                        "message": {
                          "subject": "Hello World from Microsoft Graph API",
                          "body": {
                            "contentType": "HTML",
                            "content": "This Mail is sent via Microsoft <br>
                            GRAPH <br>
                            API<br>
                            
                            "
                          },
                          "toRecipients": [
                            {
                              "emailAddress": {
                                "address": "michael.seidl@au2mator.com"
                              }
                            }
                          ]
                        },
                        "saveToSentItems": "false"
                      }
"@

Invoke-RestMethod -Method POST -Uri $URLsend -Headers $headers -Body $BodyJsonsend