function Get-APNApiEndpoint {
    <#
    .SYNOPSIS

    Returns the api uri endpoint.

    .DESCRIPTION

    Returns the api uri endpoint base on the api type.

    .PARAMETER ApiType

    Type of the api endpoint to use.

    .OUTPUTS

    String, The uri endpoint that will be used by Set-APNUri.

    .EXAMPLE

    Returns the api endpoint for 'deployments'

    Get-APApiEndpoint -ApiType deployments

    .LINK

    https://docs.appian.com/suite/help/22.1/Deployment_Rest_API.html
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]
        $ApiType
    )

    begin {
    }

    process {
        Switch ($ApiType) {
            'deployments' {
                return '/suite/deployment-management/v1/deployments'
            }
            'deployments-id' {
                return '/suite/deployment-management/v1/deployments/{0}'
            }
            'deployments-log' {
                return '/suite/deployment-management/v1/deployments/{0}/log'
            }
            'inspections' {
                return '/suite/deployment-management/v1/inspections'
            }
            'inspections-id' {
                return '/suite/deployment-management/v1/inspections/{0}'
            }
            default {
                Write-Error "[$($MyInvocation.MyCommand.Name)]: [$ApiType] is not supported" -ErrorAction Stop
            }
        }
    }

    end {
    }
}
