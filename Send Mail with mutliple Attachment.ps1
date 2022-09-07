$clientID = "yourClientID"
$Clientsecret = "yourSecret"
$tenantID = "yourTenantID"

#Configure Mail Properties
$MailSender = "michael.seidl@au2mator.com"
$Recipient = "michael.seidl@au2mator.com"

#Get File Name and Base64 string
$AttachmentArray = Get-ChildItem -Path "C:\Users\seimi\OneDrive - Seidl Michael\2-au2mator\1 - TECHGUY\GitHub\Microsoft-Graph-API-Examples" -Filter "*.docx"

$AttachmentJson = ""
foreach ($A in $AttachmentArray) {

  $FileName = (Get-Item -Path $A.FullName).name
  $base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($A.FullName))


  $AttachmentJson += @"
{
  "@odata.type": "#microsoft.graph.fileAttachment",
  "name": "$FileName",
  "contentType": "text/plain",
  "contentBytes": "$base64string"
},
"@


}

$watchdir="C:\Users\seimi\OneDrive - Seidl Michael\2-au2mator\1 - TECHGUY\GitHub\Microsoft-Graph-API-Examples"
$attach102119 = @(gci $watchdir | Where-Object {$_.Name -match "_102" -or $_.Name -match "_119"} | Select-Object -expand FullName)

$attach102119.count




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
                            and an Attachment <br>
                            "
                          },
                          
                          "toRecipients": [
                            {
                              "emailAddress": {
                                "address": "$Recipient"
                              }
                            }
                          ]
                          ,"attachments": [
                            $AttachmentJson
                          ]
                        },
                        "saveToSentItems": "false"
                      }
"@

Invoke-RestMethod -Method POST -Uri $URLsend -Headers $headers -Body $BodyJsonsend