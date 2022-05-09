function ConvertTo-APNMarkdownDeploymentReport {
    <#
    .SYNOPSIS

    Converts Appian deployment or inspection results to a markdown table.

    .DESCRIPTION

    Converts Appian deployment or inspection results to a markdown table.

    .PARAMETER DeploymentResults

    The report to format.

    .PARAMETER DeploymentLog

    The deployment log to format

    .OUTPUTS

    String, The deployment or inspection results in markdown table format

    .EXAMPLE

    $report = Get-APNDeploymentResults -Session 'mySession -DeploymentId '834895a6-6d2f-4180-b396-b9ifb4f38b0f'
    $log = Get-APNDeploymentLog -Session 'mySession' -DeploymentId '834895a6-6d2f-4180-b396-b9ifb4f38b0f'
    ConvertTo-APNMarkdownDeploymentReport -DeploymentReport $report -DeploymentLog $log

    .LINK

    https://docs.appian.com/suite/help/22.1/Deployment_Rest_API.html
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [PSObject[]]
        $DeploymentResults,

        [Parameter()]
        [string]
        $DeploymentLog
    )

    begin {
        $databaseScripts = $DeploymentResults.summary.databaseScripts
        $objects = $DeploymentResults.summary.objects
    }

    process {
        '# Deployment Results'
        '## Database Scripts'
        "- Total $databaseScripts"
        '## Objects Expected'
        "- Total $($objects.Total)"
        "- Imported $($objects.Imported)"
        "- Failed $($objects.Failed)"
        "- Skipped $($objects.Skipped)"
        # Log
        '# Deployment Log'
        $Log
    }

    end {

    }
}
