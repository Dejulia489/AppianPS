Function Update-APNSession
{
    <#
    .SYNOPSIS

    Updates an Appian session.

    .DESCRIPTION

    Updates an Appian session.
    The sensetive data is encrypted and stored in the users local application data.
    These updated sessions are available immediately.
    If the session was previously saved is will remain saved.

    .PARAMETER SessionName

    The friendly name of the session.

    .PARAMETER Domain

    The Appian site domain. Example 'mydomain.appiancloud.com'

    .PARAMETER ApiKey

    The Appian api key. The API key can be created in the Appian Administration Console, and then configured to secure external inspections.

    .PARAMETER Credential

    Specifies a user account that has permission to the project.

    .PARAMETER Proxy

    Use a proxy server for the request, rather than connecting directly to the Internet resource. Enter the URI of a network proxy server.

    .PARAMETER ProxyCredential

    Specifie a user account that has permission to use the proxy server that is specified by the -Proxy parameter. The default is the current user.

    .PARAMETER Path

    The path where module data will be stored, defaults to $Script:ModuleDataPath.

    .INPUTS

    PSbject. Get-APNSession, New-APNSession

    .OUTPUTS

    None. Update-APNSession does not generate any output.

    .EXAMPLE
    
    Updates the Appian session named 'myFirstSession'.

    Update-APNSession -SessionName 'myFirstSession' -ApiKey '*******'
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByApiKey')]
    Param
    (
        [Parameter(Mandatory)]
        [string]
        $SessionName,

        [Parameter()]
        [string]
        $Domain,

        [Parameter(ParameterSetName = 'ByApiKey')]
        [string]
        $ApiKey,

        [Parameter(ParameterSetName = 'ByCredential')]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $Proxy,

        [Parameter()]
        [pscredential]
        $ProxyCredential,
        
        [Parameter()]
        [string]
        $Path = $Script:ModuleDataPath
    )
    Begin
    {

    }
    Process
    {
        $getAPSessionSplat = @{
            SessionName = $SessionName
        }
        If ($Id)
        {
            $getAPSessionSplat.Id = $Id
        }
        $existingSessions = Get-APNSession @getAPSessionSplat
        If ($existingSessions)
        {
            Foreach ($existingSession in $existingSessions)
            {
                $newAPSessionSplat = @{
                    SessionName = $SessionName
                }
                If ($Domain)
                {
                    $newAPSessionSplat.Domain = $Domain
                }
                else
                {
                    If ($existingSession.Domain)
                    {
                        $newAPSessionSplat.Domain = $existingSession.Domain
                    }
                }
                If ($ApiKey)
                {
                    $newAPSessionSplat.ApiKey = $ApiKey
                }
                else
                {
                    If ($existingSession.ApiKey)
                    {
                        $newAPSessionSplat.ApiKey = $existingSession.ApiKey
                    }
                }
                If ($Credential)
                {
                    $_credentialObject = @{
                        Username = $Session.Credential.UserName
                        Password = ($Session.Credential.GetNetworkCredential().SecurePassword | ConvertFrom-SecureString)
                    }
                    $newAPSessionSplat.Credential = $_credentialObject
                }
                else
                {
                    If ($existingSession.Credential)
                    {
                        $newAPSessionSplat.Credential = $existingSession.Credential
                    }
                }
                If ($Proxy)
                {
                    $newAPSessionSplat.Proxy = $Session.Proxy
                }
                else
                {
                    If ($existingSession.Proxy)
                    {
                        $newAPSessionSplat.Proxy = $existingSession.Proxy
                    }
                }
                If ($ProxyCredential)
                {
                    $_proxyCredentialObject = @{
                        Username = $Session.ProxyCredential.UserName
                        Password = ($Session.ProxyCredential.GetNetworkCredential().SecurePassword | ConvertFrom-SecureString)
                    }
                    $newAPSessionSplat.ProxyCredential = $_proxyCredentialObject
                }
                else
                {
                    If ($existingSession.ProxyCredential)
                    {
                        $newAPSessionSplat.ProxyCredential = $existingSession.ProxyCredential
                    }
                }
                If ($existingSession.Saved)
                {
                    $existingSession | Remove-APNSession -Path $Path
                    $session = New-APNSession @newAPSessionSplat | Save-APNSession
                }
                else
                {
                    $existingSession | Remove-APNSession -Path $Path
                    $session = New-APNSession @newAPSessionSplat
                }
            }
        }
        else
        {
            Write-Error "[$($MyInvocation.MyCommand.Name)]: Unable to locate an AP session with the name [$SessionName]." -ErrorAction Stop
        }
    }
    End
    {
    }
}
