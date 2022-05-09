function Get-APNDeploymentResults {
    <#
    .SYNOPSIS

    Returns Appian deployment results.

    .DESCRIPTION

    Returns Appian deployment results based on the deployment id.
    The deployment id is returned in the response of New-APNDeployment.

    .PARAMETER Domain

    The Appian site domain.

    .PARAMETER ApiKey

    The Appian api key. The API key can be created in the Appian Administration Console, and then configured to secure external deployments.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .PARAMETER Proxy

    Use a proxy server for the request, rather than connecting directly to the Internet resource. Enter the URI of a network proxy server.

    .PARAMETER ProxyCredential

    Specifie a user account that has permission to use the proxy server that is specified by the -Proxy parameter. The default is the current user.

    .PARAMETER Session

    Azure DevOps PS session, created by New-APNSession.

    .PARAMETER DeploymentId

    The id of the deployment.

    .PARAMETER Wait

    Flag to wait for summary status to not be 'IN_PROGRESS'.

    .PARAMETER TimeoutSeconds

    The number of seconds to wait before timing out. Defaults to 120.

    .PARAMETER SleepSeconds

    The number of seconds to sleep inbetween requests. Defaults to 1.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    String, Appian deployment results.

    .EXAMPLE

    Returns the Appian deployment results.

    Get-APNDeploymentResults -Domain 'myAppianDomain' -ApiKey '*******' -DeploymentId '834895a6-6d2f-4180-b396-b9ifb4f38b0f'

    .LINK

    https://docs.appian.com/suite/help/22.1/Get_Deployment_Results_API.html
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByApiKey')]
    Param
    (
        [Parameter(Mandatory,
            ParameterSetName = 'ByApiKey')]
        [Parameter(Mandatory,
            ParameterSetName = 'ByCredential')]
        [string]
        $Domain,

        [Parameter(ParameterSetName = 'ByApiKey')]
        [Security.SecureString]
        $ApiKey,

        [Parameter(ParameterSetName = 'ByCredential')]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'ByApiKey')]
        [Parameter(ParameterSetName = 'ByCredential')]
        [string]
        $Proxy,

        [Parameter(ParameterSetName = 'ByApiKey')]
        [Parameter(ParameterSetName = 'ByCredential')]
        [pscredential]
        $ProxyCredential,

        [Parameter(Mandatory,
            ParameterSetName = 'BySession')]
        [object]
        $Session,

        [Parameter(Mandatory)]
        [string]
        $DeploymentId,

        [Parameter()]
        [bool]
        $Wait,

        [Parameter()]
        [int]
        $TimeoutSeconds = 120,

        [Parameter()]
        [int]
        $SleepSeconds = 1
    )

    begin {
        $timeoutIterations = $TimeoutSeconds / $SleepSeconds
        If ($PSCmdlet.ParameterSetName -eq 'BySession') {
            $currentSession = $Session | Get-APNSession
            If ($currentSession) {
                $Domain = $currentSession.Domain
                $ApiKey = $currentSession.ApiKey
                $Credential = $currentSession.Credential
                $Proxy = $currentSession.Proxy
                $ProxyCredential = $currentSession.ProxyCredential
            }
        }
    }

    process {
        $apiEndpoint = (Get-APNApiEndpoint -ApiType 'deployments-id') -f $DeploymentId
        $setAPNUriSplat = @{
            Domain      = $Domain
            ApiEndpoint = $apiEndpoint
        }
        [uri] $uri = Set-APNUri @setAPNUriSplat
        $invokeAPNRestMethodSplat = @{
            Method          = 'GET'
            Uri             = $uri
            Credential      = $Credential
            ApiKey          = $ApiKey
            Proxy           = $Proxy
            ProxyCredential = $ProxyCredential
        }
        $results = Invoke-APNRestMethod @invokeAPNRestMethodSplat
        If ($Wait) {
            $i = 0
            while (($results.Status -eq 'IN_PROGRESS') -or ($results.Status -eq 'PENDING_REVIEW')) {
                Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Sleeping for $SleepSeconds seconds"
                Start-Sleep -Seconds $SleepSeconds
                $i = $i + 1
                If ($i -gt $timeoutIterations) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Timeout reached it's maximum of $TimeoutSeconds seconds."
                    break
                }
                $results = Get-APNDeploymentResults @PSBoundParameters
            }
        }
        return $results
    }

    end {
    }
}