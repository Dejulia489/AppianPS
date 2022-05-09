function Set-APNUri {
    <#
    .SYNOPSIS

    Sets the uri used by Invoke-APNRestMethod.

    .DESCRIPTION

    Sets the uri used by Invoke-APNRestMethod.

    .PARAMETER Domain

    The Appian site domain.

    .PARAMETER ApiEndpoint

    The api endpoint provided by Get-APNApiEndpoint.

    .OUTPUTS

    Uri, The uri that will be used by Invoke-APNRestMethod.

    .EXAMPLE

    Set-APNUri -Domain 'myAppianDomain' -ApiEndpoint suite/deployment-management/v1/deployments

    .LINK

    https://docs.appian.com/suite/help/22.1/Deployment_Rest_API.html
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [string]
        $Domain,

        [Parameter(Mandatory)]
        [string]
        $ApiEndpoint
    )

    begin {
    }

    process {
        return 'https://{0}{1}' -f $Domain, $ApiEndpoint
    }

    end {
    }
}
