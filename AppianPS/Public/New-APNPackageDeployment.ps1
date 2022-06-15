function New-APNPackageDeployment {
    <#
    .SYNOPSIS

    Creates an Appian package deployment.

    .DESCRIPTION

    Creates an Appian package deployment.

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

    .PARAMETER Name

    Name of the deployment. This name will appear in the deployments view in Appian Designer.

    .PARAMETER Description

    Description of the deployment. This description will appear in the deployments view in Appian Designer.

    .PARAMETER PackageFilePath

    The local path to the package.

    .PARAMETER CustomizationFilePath

    The local path to the import customization file (.properties).

    .PARAMETER DataSource

    Name or UUID of the data source. If the data source is connected through the Administration Console, use the value in the Name field. If the data source is connected through a data source connected system, use the UUID of the connected system.

    .PARAMETER DatabaseScriptPath

    One or multiple paths to a script file; scripts will be executed in alphabetical order.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject, Appian deployment object

    .EXAMPLE


    .LINK

    https://docs.appian.com/suite/help/22.1/Deploy_Package_API.html
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
        $Name,

        [Parameter()]
        [string]
        $Description,

        [Parameter(Mandatory)]
        [string]
        $PackageFilePath,

        [Parameter()]
        [string]
        $CustomizationFilePath,

        [Parameter()]
        [string]
        $DataSource,

        [Parameter()]
        [string[]]
        $DatabaseScriptPath
    )

    begin {
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
        $package = Get-Item -Path $PackageFilePath
        $json = @{
            name            = $Name
            packageFileName = $package.Name
        } 
        if ($Description) {
            $json.description = $Description
        }
        if ($DataSource) {
            $json.dataSource = $DataSource
        }
        $form = @{
            zipFile = $package
        }
        if ($CustomizationFilePath) {
            $propertiesFile = Get-Item -Path $CustomizationFilePath
            $json.customizationFileName = $propertiesFile.Name
            $form.propertiesFile = $propertiesFile
        }
        if ($DatabaseScriptPath) {
            $databaseScripts = @()
            $orderId = 1
            $scripts = Get-Item -Path $DatabaseScriptPath
            foreach ($script in $scripts | Sort-Object -Property 'Name') {
                $databaseScripts += @{
                    fileName = $script.Name
                    orderId  = $orderId
                }
                $form.$($script.name) = $script
                $orderId ++
            }
            $json.databaseScripts = $databaseScripts
        }
        $form.json = $json | ConvertTo-Json
        $apiEndpoint = Get-APNApiEndpoint -ApiType 'deployments'
        $setAPNUriSplat = @{
            Domain      = $Domain
            ApiEndpoint = $apiEndpoint
        }
        [uri] $uri = Set-APNUri @setAPNUriSplat
        $invokeAPNRestMethodSplat = @{
            Form            = $form
            Method          = 'POST'
            Uri             = $uri
            Credential      = $Credential
            ApiKey          = $ApiKey
            Proxy           = $Proxy
            ProxyCredential = $ProxyCredential
        }
        $results = Invoke-APNRestMethod @invokeAPNRestMethodSplat
        return $results
    }

    end {
    }
}