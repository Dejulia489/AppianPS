Function Remove-APNSession {
    <#
    .SYNOPSIS

    Removes an Appian session.

    .DESCRIPTION

    Removes an Appian session.
    If the session is saved, it will be removed from the saved sessions as well.

    .PARAMETER Id

    Session id.

    .PARAMETER Path

    The path where session data will be stored, defaults to $Script:ModuleDataPath.

    .LINK

    Save-APNSession
    Remove-APNSession

    .INPUTS

    PSObject. Get-APNSession

    .OUTPUTS

    None. Does not supply output.

    .EXAMPLE

    Deletes AP session with the id of '2'.

    Remove-APNSession -Id 2

    .EXAMPLE

    Deletes all AP sessions in memory and stored on disk.

    Remove-APNSession

    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName)]
        [int]
        $Id,
       
        [Parameter()]
        [string]
        $Path = $Script:ModuleDataPath
    )
    Process {
        $sessions = Get-APNSession -Id $Id
        Foreach ($session in $sessions) {
            If ($session.Saved -eq $true) {
                $newData = @{SessionData = @() }
                $data = Get-Content -Path $Path -Raw | ConvertFrom-Json
                Foreach ($_data in $data.SessionData) {
                    If ($_data.Id -eq $session.Id) {
                        Continue
                    }
                    else {
                        $newData.SessionData += $_data
                    }
                }
                $newData | ConvertTo-Json -Depth 5 | Out-File -FilePath $Path
            }
            [array] $Global:_APNSessions = $Global:_APNSessions | Where-Object { $PSItem.Id -ne $session.Id }
        }
    }
}