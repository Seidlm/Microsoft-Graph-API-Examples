$clientID = "your Client ID"
$Clientsecret = "your Secret"
$tenantID = "your Tenant ID"


$DB="Database Name"
$Serverinstance="yourSQLserver.database.windows.net"
$Query="SELECT * FROM [dbo].[Table] order by Date desc"


$Modules = @("sqlServer") 

foreach ($Module in $Modules) {
    if (Get-Module -ListAvailable -Name $Module) {
        # "Module is already installed:  $Module"        
    }
    else {
        W# "Module is not installed, try simple method:  $Module"
        try {
            Install-Module $Module -Force -Confirm:$false
            # "Module was installed the simple way:  $Module"
        }
        catch {
            # "Module is not installed, try the advanced way:  $Module"
            try {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                Install-PackageProvider -Name NuGet  -MinimumVersion 2.8.5.201 -Force
                Install-Module $Module -Force -Confirm:$false
                # "Module was installed the advanced way:  $Module"
            }
            catch {
               # "could not install module:  $Module"

            }
        }
    }

    # "Import Module:  $Module"
    Import-module $Module
}


#Get Token for autentication
$request = Invoke-RestMethod -Method POST `
           -Uri "https://login.microsoftonline.com/$tenantid/oauth2/token"`
           -Body @{ resource="https://database.windows.net/"; grant_type="client_credentials"; client_id=$clientid; client_secret=$Clientsecret }`
           -ContentType "application/x-www-form-urlencoded"
$access_token = $request.access_token


#Run SQL Command with accessToken
Invoke-Sqlcmd -ServerInstance $Serverinstance -Database $DB -AccessToken $access_token -query $Query

y