$clientID_OneDrive = "your Client ID"
$Clientsecret_OneDrive = "your Secret"
$tenantID = "your Tenant ID"

$GraphBaseURL="https://graph.microsoft.com/v1.0"

#OneDrive User
$UserUPN="youer UPN"

#Authentication
$tokenBody_OneDrive = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientID_OneDrive
    Client_Secret = $Clientsecret_OneDrive
}
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method POST -Body $tokenBody_OneDrive
$headers_OneDrive = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type"  = "application/json"
}

#Get the Drive ID
$Drive = Invoke-RestMethod -Uri "$GraphBaseURL/users/$UserUPN/drive" -Method GET -Headers $headers_OneDrive

#Get the Folder
$DestFolder = Invoke-RestMethod -Uri "$GraphBaseURL/users/$UserUPN/drives/$($Drive.id)/root:/0-Temp" -Method GET -Headers $headers_OneDrive 





#Word Document
$File="Hello World.docx"
$fileName=$File.Split("\")[-1]
#Upload
Invoke-RestMethod -Uri "$GraphBaseURL/users/$UserUPN/drives/$($Drive.id)/items/$($DestFolder.id):/$($FileName):/content" -Method PUT -Headers $headers_OneDrive -InFile $file -ContentType 'application/docx'


#pdf Document
$File="Hello World.pdf"
$fileName=$File.Split("\")[-1]
#Upload
Invoke-RestMethod -Uri "$GraphBaseURL/users/$UserUPN/drives/$($Drive.id)/items/$($DestFolder.id):/$($FileName):/content" -Method PUT -Headers $headers_OneDrive -InFile $file -ContentType 'application/pdf'


#TXT Document
$File="Hello World.txt"
$fileName=$File.Split("\")[-1]
#Upload
Invoke-RestMethod -Uri "$GraphBaseURL/users/$UserUPN/drives/$($Drive.id)/items/$($DestFolder.id):/$($FileName):/content" -Method PUT -Headers $headers_OneDrive -InFile $file -ContentType 'plain/text'



#Image
$File="Hello World.png"
$fileName=$File.Split("\")[-1]
#Upload
Invoke-RestMethod -Uri "$GraphBaseURL/users/$UserUPN/drives/$($Drive.id)/items/$($DestFolder.id):/$($FileName):/content" -Method PUT -Headers $headers_OneDrive -InFile $file -ContentType 'image/png'
