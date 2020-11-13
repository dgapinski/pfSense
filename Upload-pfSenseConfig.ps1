<#
This is sample code for the purpose of uploading to current pfSense routers. Add parameters or functionalize this to your liking.

+ It was tested with Powershell 7. Powershell 6 might work, but no promises.
- Running in ISE does not work.
- Tested with pfSense 2.4 software on Netgate SG-2440 and Netgate SG-3100 routers

#>

$Timeout = 15
$restorearea='aliases'
$conffile='c:\path\aliases.xml' # A backup file that you want to upload
$PW = 'pfsense'
$Uri = 'https://192.168.1.1'


# ENTRY POINT - get the login page
$CsrfToken = $null;							
$LoginPage = Invoke-WebRequest -TimeoutSec $Timeout -Uri $Uri -SessionVariable Session 
$CsrfToken = $LoginPage.InputFields.FindByName('__csrf_magic').Value

$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList 'admin', (ConvertTo-SecureString -AsPlainText -Force ($PW))
$Creds = @{
	__csrf_magic=$CsrfToken;
	usernamefld=$Credential.GetNetworkCredential().UserName;
	passwordfld=$Credential.GetNetworkCredential().Password;
	login='Login'
	}
            
# Login to web portal
$Result = Invoke-WebRequest -TimeoutSec $Timeout -WebSession $Session -Uri $uri -Method Post -Body $Creds 
$CsrfToken = $Result.InputFields.FindByName('__csrf_magic').Value

# Get backup pagethat 
$Result = Invoke-WebRequest -TimeoutSec $Timeout -WebSession $Session -Uri "$uri/diag_backup.php" 
$CsrfToken = $Result.InputFields.FindByName('__csrf_magic').Value

$RestoreArguments =  @{
    __csrf_magic=$CsrfToken
    donotbackuprrd='yes'
    encrypt_password=''
    conffile=get-item -path $conffile
    decrypt_password=''
    restorearea=$RestoreArea
    backuparea=''
    restore='Restore Configuration'
    }
$Result = Invoke-WebRequest -TimeoutSec $Timeout -WebSession $Session -Uri "$uri/diag_backup.php" -Method 'POST' -form $RestoreArguments 


0
