$clientID = "your ID"
$Clientsecret = "your Secret"
$tenantID = "Your Tenant"

$TeamName="Techguy Team"
$TeamDescription="The official Team for Techguy.at"
$TeamVisibility="public" #public, private
$Owner="michael@techguy.at"


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


#Get Owner ID

$URLOwnwer = "https://graph.microsoft.com/v1.0/users/$Owner"
$ResultOwner = Invoke-RestMethod -Headers $headers -Uri $URLOwnwer -Method Get


#Create Teams
$BodyJsonTeam = @"
            {
               "template@odata.bind":"https://graph.microsoft.com/v1.0/teamsTemplates('standard')",
               "displayName":"$TeamName",
               "description":"$TeamDescription",
               "visibility":"$TeamVisibility",
               "members":[
                  {
                     "@odata.type":"#microsoft.graph.aadUserConversationMember",
                     "roles":[
                        "owner"
                     ],
                     "user@odata.bind":"https://graph.microsoft.com/v1.0/users/$($ResultOwner.id)"
                  }
               ]
            }
"@
            $URLTeam = "https://graph.microsoft.com/v1.0/teams"

            Invoke-RestMethod -Headers $headers -Uri $URLTeam -Method POST -Body $BodyJsonTeam 




