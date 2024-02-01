$clientID = "your Client ID"
$Clientsecret = "your Secret"
$tenantID = "your Tenant ID"

$Graph_BaseURL = "https://graph.microsoft.com/v1.0"


#Calendar User
$TargetUser="michael.seidl@au2mator.com"


#Simple Event Details
$EventSubject = "My GRAPH API Event"
$EventBody = "Thats my awesome GRAPH API Event Body"
$EventLocation = "Microsoft Headquarter"

$EventStart = "2024-02-10T09:00:00"
$EventEnd = "2024-02-10T10:00:00"
$timeZone = "UTC"



#Teams Event Details
$TeamsEventSubject = "My Teams-GRAPH API Event"
$TeamsEventBody = "Thats my awesome Teams-GRAPH API Event Body"

$TeamsEventStart = "2024-02-11T09:00:00"
$TeamsEventEnd = "2024-02-11T10:00:00"
$timeZone = "UTC"



#Authentication
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



$SimpleEventJson = @"
{
  "subject": "$EventSubject",
  "location":{
    "displayName":"$EventLocation",
    "address":{
        "street":"4567 Main St",
        "city":"Redmond",
        "state":"WA",
        "countryOrRegion":"US",
        "postalCode":"32008"
      },
},
  "body": {
    "contentType": "HTML",
    "content": "$($EventBody)"
  },
  "start": {
      "dateTime": "$($EventStart)",
      "timeZone": "$timeZone"
  },
  "end": {
      "dateTime": "$($EventEnd)",
      "timeZone": "$timeZone"
  }
}
"@

$SimpleEvent = Invoke-RestMethod -Uri "$Graph_BaseURL/users/$TargetUser/calendar/events" -Method POST -Headers $headers -Body $simpleEventJson -ContentType "application/json; charset=utf-8"




$TeamsEventJson = @"
{
  "subject": "$TeamsEventSubject",
  "isOnlineMeeting": true,
  "onlineMeetingProvider": "teamsForBusiness",
  "attendees": [
    {
      "emailAddress": {
        "address":"ahmed.uzejnovic@au2mator.com",
        "name": "Ahmed Uzejnovic"
      },
      "type": "required"
    }
  ],
  "body": {
    "contentType": "HTML",
    "content": "$($TeamsEventBody)"
  },
  "start": {
      "dateTime": "$($TeamsEventStart)",
      "timeZone": "$timeZone"
  },
  "end": {
      "dateTime": "$($TeamsEventEnd)",
      "timeZone": "$timeZone"
  }
}
"@


$TeamsEvent = Invoke-RestMethod -Uri "$Graph_BaseURL/users/$TargetUser/calendar/events" -Method POST -Headers $headers -Body $TeamsEventJson -ContentType "application/json; charset=utf-8"
