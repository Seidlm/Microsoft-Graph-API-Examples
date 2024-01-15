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
#$URLsend = "https://graph.microsoft.com/v1.0/users/$MailSender/sendMail"
#compared to sending an email, we use the endpoint messages
$URLDraft = "https://graph.microsoft.com/v1.0/users/$MailSender/messages"

#Also the body is a bit different compared to send an email
$BodyJsonDraft = @"
                    {
                          "subject": "Hello World from Microsoft Graph API",
                          "body": {
                            "contentType": "HTML",
                            "content": "This is a draft Mail <br>
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
                      }
"@

Invoke-RestMethod -Method POST -Uri $URLDraft -Headers $headers -Body $BodyJsonDraft