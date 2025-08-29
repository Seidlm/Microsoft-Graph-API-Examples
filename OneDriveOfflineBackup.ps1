# This Script is valued with around 2000 Euro
# You get it for free
# it saved you around 2+ Days of work
# it solves a Problem you have
# all for free
# show your support here: https://github.com/sponsors/Seidlm


#OneDrive GRAPH API Details
$clientID_OneDrive = "your Client ID"
$Clientsecret_OneDrive = "your Secret"
$tenantID = "Tenant ID"


#region functions
function Request-AccessToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [string]$TenantName,
        [Parameter(Mandatory = $true)] [string]$ClientId,
        [Parameter(Mandatory = $true)] [string]$ClientSecret
    )

    $tokenBody = @{
        Grant_Type    = 'client_credentials'
        Scope         = 'https://graph.microsoft.com/.default'
        Client_Id     = $ClientId
        Client_Secret = $ClientSecret
    }

    Write-Debug "Requesting a new access token from Microsoft Identity Platform..."

    try {
        $tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token" -Method POST -Body $tokenBody -ErrorAction Stop
        $global:accessToken = $tokenResponse.access_token
        $global:tokenExpiresAt = (Get-Date).AddSeconds($tokenResponse.expires_in)
        $global:headers = @{
            "Authorization" = "Bearer $($global:accessToken)"
            "Content-type"  = "application/json"
        }
    }
    catch {
        Write-Output "Error generating access token: $($_.Exception.Message)"
        Write-Output "Exception Details: $($_.Exception)"
        return $null
    }
    Write-Output "Successfully generated authentication token"
    return $tokenResponse
}
# Function to renew the access token when close to expiration
function Renew-AccessToken {
    param (
        [string]$TenantName,
        [string]$ClientId,
        [string]$ClientSecret
    )

    Write-Debug "Attempting to renew the access token..."
    try {
        $tokenResponse = Request-AccessToken -TenantName $TenantName -ClientId $ClientId -ClientSecret $ClientSecret

        if ($null -ne $tokenResponse) {
            # Update the global access token and expiration time
            $global:accessToken = $tokenResponse.access_token
            $global:tokenExpiresAt = (Get-Date).AddSeconds($tokenResponse.expires_in)
            Write-Output "Token renewed successfully. New expiration time: $global:tokenExpiresAt"
        }
        else {
            Write-Output "Failed to renew the access token. Response was null."
        }
    }
    catch {
        Write-Output "Error renewing the access token: $($_.Exception.Message)"
    }
}
function Check-TokenExpiration {
    try {
        Write-Host "Checking token expiration at: $(Get-Date)..." 
        # Check if the token is about to expire (1 minute before expiration)
        if ((Get-Date) -ge $global:tokenExpiresAt.AddMinutes(-$minutesbeforetokenexpires)) {
            Write-Host "Access token is expired or close to expiration. Renewing the token..." -ForegroundColor DarkYellow
            Renew-AccessToken -TenantName $tenantID -ClientId $clientID_OneDrive -ClientSecret $Clientsecret_OneDrive
        }
        else {
            Write-Host "Access token is still valid. Expires at: $global:tokenExpiresAt" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Error in Check-TokenExpiration function: $($_.Exception.Message)" -ForegroundColor Red
    }
}

#endregion functions


# Define global variables for the access token and expiration time
$global:accessToken = $null
$global:tokenExpiresAt = [datetime]::MinValue
$global:headers = $null
$tokencheckinterval = 300000  # 300 seconds (300000 milliseconds) -> Can be bigger in production.
$minutesbeforetokenexpires = 6 # Set how many minutes before token expiration the token should be renewed

# Request the initial token
$tokenResponse = Request-AccessToken -TenantName $tenantID -ClientId $clientID_OneDrive -ClientSecret $Clientsecret_OneDrive

#This is the Interval the  Token Check Takes place ! 
$timer = New-Object Timers.Timer
$timer.Interval = $tokencheckinterval
$Aktion = { Check-TokenExpiration }            
            
# Register the event handler to check token expiration
try {
    $timerEvent = Register-ObjectEvent -InputObject $timer -EventName Elapsed -SourceIdentifier "TokenCheck" -Action $Aktion
    Write-Output "Event registered successfully."
}
catch {
    Write-Output "Failed to register the timer event: $($_.Exception.Message)"
}

# Start the timer and verify that it is running
$timer.Start()
if ($timer.Enabled) {
    Write-Output "Timer started successfully. Access token will be checked for renewal every $($timer.Interval/1000) seconds."
}
else {
    Write-Output "Failed to start the timer."
}



#Destionation Folder
$Dest = "Y:\OneDrive - *YourUPN*"

#OneDrive Details
$Drive = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/*YourUPN*/drive" -Method GET -Headers $global:headers
$Child = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/*YourUPN*/drives/$($Drive.id)/root/children" -Method GET -Headers $global:headers


Function Download-Item {
    param (
        [object]$ItemObject,
        [hashtable]$Headers
    )
    $ItemID = $ItemObject.id

    if ($ItemObject.folder -ne $null) {
        #Folder
        $ParentFolder = "$Dest\$($ItemObject.parentReference.path.Split("root:/")[1])"
        if (-not (Test-Path -Path $ParentFolder)) {
            New-Item -ItemType Directory -Path $ParentFolder -Force | Out-Null
        }
        $SubItemObject = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/michael.seidl@au2mator.com/drives/$($Drive.id)/items/$($ItemID)/children" -Method GET -Headers $global:headers
        foreach ($item in $SubItemObject.value | Sort-Object -Property size -Descending) {
            Download-Item -ItemObject $item -Headers $global:headers
        }           
    }
    elseif ($ItemObject.file -ne $null) {
        #File
        $ParentFolder = "$Dest\$($ItemObject.parentReference.path.Split("root:/")[1])"
        $ParentFolder = $ParentFolder.Replace("/$($ItemObject.name)", '')
        if (-not (Test-Path -Path $ParentFolder)) {
            New-Item -ItemType Directory -Path $ParentFolder -Force | Out-Null
        }

        $ParentFolder = "$ParentFolder\$($ItemObject.name)"
        $Download = $false
        try {
            $LocalFile = Get-Item -Path $ParentFolder -ErrorAction Stop
            if ($LocalFile -and ($LocalFile.LastWriteTime -lt $ItemObject.lastModifiedDateTime)) {
                $Download = $true
            }
        }
        catch {
            $Download = $true
        }

        if ($Download) {
            write-Output "Downloading File: $($ItemObject.name) to $ParentFolder"
            Start-Job  -ScriptBlock {
                param($ItemID, $Headers, $ParentFolder, $Drive)
                Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/michael.seidl@au2mator.com/drives/$($Drive.id)/items/$($ItemID)/content" -Method GET -Headers $Headers -OutFile $ParentFolder
            } -ArgumentList $ItemID, $Headers, $ParentFolder, $Drive | Out-Null
        }
    }
    else {  
    }    
}


#Main part
foreach ($item in $Child.value | Sort-Object -Property size -Descending) {
    Download-Item -ItemObject $item  -Headers $headers 
}



# Stop the timer and unregister the event when done
Write-Output "Stopping the timer and unregistering the event..."
$timer.Stop()
Unregister-Event -SourceIdentifier "TokenCheck"
$timer.Dispose()
Write-Output "Timer stopped. Final Access Token Expiration: $global:tokenExpiresAt"