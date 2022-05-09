Function New-APNSession {
    <#
    .SYNOPSIS

    Creates an Appian session.

    .DESCRIPTION

    Creates an Appian session.
    Use Save-APNSession to persist the session data to disk.
    Save the session to a variable to pass the session to other functions.

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

    .LINK

    Save-APNSession
    Remove-APNSession

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject. New-APNSession returns a PSObject that contains the following:
        Domain
        ApiKey

    .EXAMPLE

    Creates a Appian session names 'myFirstSession'

    New-APNSession -SessionName 'myFirstSession' -Domain 'myAppianDomain.appiancloud.com' -ApiKey '********'
#>

    [CmdletBinding(DefaultParameterSetName = 'ByApiKey')]
    Param
    (
        [Parameter(Mandatory)]
        [string]
        $SessionName,

        [Parameter(Mandatory)]
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
    Process {
        [int] $_sessionIdcount = (Get-APNSession | Sort-Object -Property 'Id' | Select-Object -Last 1 -ExpandProperty 'Id') + 1
        $_session = New-Object -TypeName PSCustomObject -Property @{
            Domain      = $Domain
            SessionName = $SessionName
            Id          = $_sessionIdcount
        }
        If ($ApiKey) {
            $securedPat = (ConvertTo-SecureString -String $ApiKey -AsPlainText -Force)
            $_session | Add-Member -NotePropertyName 'ApiKey' -NotePropertyValue $securedPat
        }
        If ($Credential) {
            $_session | Add-Member -NotePropertyName 'Credential' -NotePropertyValue $Credential
        }
        If ($Proxy) {
            $_session | Add-Member -NotePropertyName 'Proxy' -NotePropertyValue $Proxy
        }
        If ($ProxyCredential) {
            $_session | Add-Member -NotePropertyName 'ProxyCredential' -NotePropertyValue $ProxyCredential
        }
        If ($null -eq $Global:_APNSessions) {
            $Global:_APNSessions = @()
        }
        $Global:_APNSessions += $_session
        return $_session
    }
}
