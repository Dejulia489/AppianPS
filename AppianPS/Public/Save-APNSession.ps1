Function Save-APNSession {
    <#
    .SYNOPSIS

    Saves an Appian session to disk.

    .DESCRIPTION

    Saves an Appian session to disk.
    The sensetive data is encrypted and stored in the users local application data.
    These saved sessions will be available next time the module is imported.

    .PARAMETER Session

    Appian session, created by New-APNSession.

    .PARAMETER Path
    
    The path where session data will be stored, defaults to $Script:ModuleDataPath.

    .PARAMETER PassThru
    
    Returns the saved session object.
    
    .INPUTS

    PSbject. Get-APNSession, New-APNSession

    .OUTPUTS

    None. Save-APNSession does not generate any output.

    .EXAMPLE

    Creates a session with the name of 'myFirstSession' and saves it to disk.

    $newAPNSession = @{
        SessionName = 'myFirstSession'
        Domain = 'myAppianDomain.appiancloud.com'
        ApiKey = '********'
    }
    New-APNSession @newAPNSession | Save-APNSession
    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory,
            ValueFromPipeline)]
        [object]
        $Session,
       
        [Parameter()]
        [string]
        $Path = $Script:ModuleDataPath
    )
    Begin {
        If (-not(Test-Path $Path)) {
            $data = @{SessionData = @() }
        }
        else {
            $data = Get-Content -Path $Path -Raw | ConvertFrom-Json
        }
    }
    Process {
        If ($data.SessionData.Id -notcontains $session.Id) {
            $_object = @{
                Domain      = $session.Domain
                SessionName = $session.SessionName
                Id          = $Session.Id
                Saved       = $true
            }
            If ($Session.ApiKey) {
                $_object.ApiKey = ($Session.ApiKey | ConvertFrom-SecureString) 
            }
            If ($Session.Credential) {
                $_credentialObject = @{
                    Username = $Session.Credential.UserName
                    Password = ($Session.Credential.GetNetworkCredential().SecurePassword | ConvertFrom-SecureString)
                }
                $_object.Credential = $_credentialObject
            }
            If ($Session.Proxy) {
                $_object.Proxy = $Session.Proxy
            }
            If ($Session.ProxyCredential) {
                $_proxyCredentialObject = @{
                    Username = $Session.ProxyCredential.UserName
                    Password = ($Session.ProxyCredential.GetNetworkCredential().SecurePassword | ConvertFrom-SecureString)
                }
                $_object.ProxyCredential = $_proxyCredentialObject
            }
            $data.SessionData += $_object
            $session | Remove-APNSession -Path $Path
        }
    }
    End {
        $data | ConvertTo-Json -Depth 5 | Out-File -FilePath $Path
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]: [$SessionName]: Session data has been stored at [$Path]"
    }
}
