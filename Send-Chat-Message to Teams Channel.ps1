$clientID = "your ID"
$User="your User"
$PW="your PW"
$resource = "https://graph.microsoft.com"

$TeamName="Techguy Team"
$ChannelName="Testing Channel"


#Connect to GRAPH API
$tokenBody = @{  
    Grant_Type = "password"  
    Scope      = "user.read%20openid%20profile%20offline_access"  
    Client_Id  = $clientId  
    username   =  $User
    password   = $pw
    resource  = $resource
}   

$tokenResponse = Invoke-RestMethod "https://login.microsoftonline.com/common/oauth2/token" -Method Post -ContentType "application/x-www-form-urlencoded" -Body $tokenBody -ErrorAction STOP
$headers = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type"  = "application/json"
}



#Get ID for the Team
$URLgetteamid="https://graph.microsoft.com/v1.0/groups?$select=id,resourceProvisioningOptions"
$TeamID=((Invoke-RestMethod -Method GET -Uri $URLgetteamid  -Headers $headers).value | Where-Object -property displayName -value $TeamName -eq).id


#Get ID for the Channel
$URLgetchannelid="https://graph.microsoft.com/v1.0/teams/$TeamID/channels"
$ChannelID=((Invoke-RestMethod -Method GET -Uri $URLgetchannelid  -Headers $headers).value | Where-Object -property displayName -value $ChannelName -eq).id



#Send Message in channel
$URLchatmessage="https://graph.microsoft.com/v1.0/teams/$TeamID/channels/$ChannelID/messages"
$BodyJsonTeam = @"
            
                {
                    "body": {
                      "content": "Hello World"
                    }
                  }
            
"@


Invoke-RestMethod -Method POST -Uri $URLchatmessage -Body $BodyJsonTeam -Headers $headers