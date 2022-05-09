Function Get-APNSession {
    <#
    .SYNOPSIS

    Returns Appian session data.

    .DESCRIPTION

    Returns Appian session data that has been stored in the users local application data.
    Use Save-APNSession to persist the session data to disk.
    The sensetive data is returned encrypted.

    .PARAMETER Id

    Session id.

    .PARAMETER SessionName

    The friendly name of the session.

    .PARAMETER Path

    The path where session data will be stored, defaults to $Script:ModuleDataPath.

    .LINK

    Save-APNSession
    Remove-APNSession

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject. Get-APNSession returns a PSObject that contains the following:
        Domain
        ApiKey

    .EXAMPLE

    Returns all Appian sessions saved or in memory.

    Get-APNSession

    .EXAMPLE

    Returns Appian session with the session name of 'myFirstSession'.

    Get-APNSession -SessionName 'myFirstSession'
    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [string]
        $SessionName,

        [Parameter(ParameterSetName = 'ById', 
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [int]
        $Id,

        [Parameter()]
        [string]
        $Path = $Script:ModuleDataPath
    )
    Process {
        # Process memory sessions 
        $_sessions = @()
        If ($null -ne $Global:_APNSessions) {
            Foreach ($_memSession in $Global:_APNSessions) {
                $_sessions += $_memSession
            }
        }
        
        # Process saved sessions
        If (Test-Path $Path) {
            $data = Get-Content -Path $Path -Raw | ConvertFrom-Json
            Foreach ($_data in $data.SessionData) {
                $_object = New-Object -TypeName PSCustomObject -Property @{
                    Id          = $_data.Id
                    Domain      = $_data.Domain
                    SessionName = $_data.SessionName
                    Saved       = $_data.Saved
                }
                If ($_data.ApiKey) {
                    $_object | Add-Member -NotePropertyName 'ApiKey' -NotePropertyValue ($_data.ApiKey | ConvertTo-SecureString)
                }
                If ($_data.Credential) {
                    $_psCredentialObject = [pscredential]::new($_data.Credential.Username, ($_data.Credential.Password | ConvertTo-SecureString))
                    $_object | Add-Member -NotePropertyName 'Credential' -NotePropertyValue $_psCredentialObject
                }
                If ($_data.Proxy) {
                    $_object | Add-Member -NotePropertyName 'Proxy' -NotePropertyValue $_data.Proxy
                }
                If ($_data.ProxyCredential) {
                    $_psProxyCredentialObject = [pscredential]::new($_data.ProxyCredential.Username, ($_data.ProxyCredential.Password | ConvertTo-SecureString))
                    $_object | Add-Member -NotePropertyName 'ProxyCredential' -NotePropertyValue $_psProxyCredentialObject
                }
                $_sessions += $_object
            }
        }
        If ($PSCmdlet.ParameterSetName -eq 'ById') {
            $_sessions = $_sessions | Where-Object { $PSItem.Id -eq $Id }
        }
        If ($SessionName) {
            $_sessions = $_sessions | Where-Object { $PSItem.SessionName -eq $SessionName }
            If (-not($_sessions)) {
                Write-Error "[$($MyInvocation.MyCommand.Name)]: Unable to locate a session by the name of [$SessionName]" -ErrorAction 'Stop'
            }
        }
        return $_sessions
    }
}