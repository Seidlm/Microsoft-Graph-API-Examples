#OneDrive Detais
$OneDrive_User="michael.seidl@au2mator.com" #User UPN for OneDrive
$OneDrive_Path="0-Temp" # Full path in OneDrive from root, example "0-Temp/My Files/Folder1"
$OneDrive_FileName = "Hello World.pdf" #File Name to send in the Path from above


#Global GRAPH API Details
$tenantID = "your Tenant ID"
$GraphAPI_BaseURL="https://graph.microsoft.com/v1.0"



#OneDrive Graph API Details
$clientID_OneDrive = "Your Client ID for OneDrive"
$Clientsecret_OneDrive = "your Scret"

#Mail Graph API Details
$clientID_Mail = "your Client ID for Mail"
$Clientsecret_Mail = "your Secret"



#Mail Details
$MailSender="michael.seidl@au2mator.com"
$Recipient="michael.seidl@au2mator.com"

#Graph API Authentication
$tokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientID_OneDrive
    Client_Secret = $Clientsecret_OneDrive
}
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method POST -Body $tokenBody
$headers_OneDrive = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type"  = "application/json"
}



#Define temp File Donwload Path
$Out = "$env:TEMP\$OneDrive_FileName" 

#Get File from OneDrive
#Get the Drive for the next step
$Drive = Invoke-RestMethod -Uri "$GraphAPI_BaseURL/users/$OneDrive_User/drive" -Method GET -Headers $headers_OneDrive

#Get all Child Elements from your folder
$DestFolder = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/michael.seidl@au2mator.com/drives/$($Drive.id)/root:/$($OneDrive_Path):/children" -Method GET -Headers $headers_OneDrive 

#Query your file
$FileQuery=$DestFolder.value | Where-Object -Property name -Value "$OneDrive_FileName" -eq

#Download your File
Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/michael.seidl@au2mator.com/drives/$($Drive.id)/items/$($FileQuery.id)/content" -Method GET -Headers $headers_OneDrive -OutFile $Out


  
#Convert File to Base64
$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($Out))



#Send Mail
#Connect to GRAPH API
$tokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientID_Mail
    Client_Secret = $Clientsecret_Mail
}
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method POST -Body $tokenBody
$headers_Mail = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type"  = "application/json"
}





#Send Mail
$URLsend = "https://graph.microsoft.com/v1.0/users/$MailSender/sendMail"
$BodyJsonsend = @"
                    {
                        "message": {
                          "subject": "au2mator $InvoiceNumber",
                          "body": {
                            "contentType": "HTML",
                            "content": "$MailText
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
                            {
                              "@odata.type": "#microsoft.graph.fileAttachment",
                              "name": "$($OneDrive_FileName)",
                              "contentType": "text/plain",
                              "contentBytes": "$base64string "
                            }
                          ]
                        },
                        "saveToSentItems": "true"
                      }
"@



Invoke-RestMethod -Method POST -Uri $URLsend -Headers $headers_Mail -Body $BodyJsonsend  -ContentType "application/json; charset=utf-8"

