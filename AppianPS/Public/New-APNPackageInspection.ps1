function New-APNPackageInspection {
    <#
    .SYNOPSIS

    Creates an Appian package inspection.

    .DESCRIPTION

    Creates an Appian package inspection.

    .PARAMETER Domain

    The Appian site domain.

    .PARAMETER ApiKey

    The Appian api key. The API key can be created in the Appian Administration Console, and then configured to secure external inspections.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .PARAMETER Proxy

    Use a proxy server for the request, rather than connecting directly to the Internet resource. Enter the URI of a network proxy server.

    .PARAMETER ProxyCredential

    Specifie a user account that has permission to use the proxy server that is specified by the -Proxy parameter. The default is the current user.

    .PARAMETER Session

    Azure DevOps PS session, created by New-APNSession.

    .PARAMETER PackageFilePath

    The local path to the package.

    .PARAMETER CustomizationFilePath

    The local path to the import customization file (.properties).

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject, Appian inspection object

    .EXAMPLE


    .LINK

    https://docs.appian.com/suite/help/22.1/Inspect_Package_API.html
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
        $PackageFilePath,

        [Parameter()]
        [string]
        $CustomizationFilePath
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
            packageFileName = $package.Name
        } 
        $form = @{
            zipFile = $package
        }
        if ($CustomizationFilePath) {
            $propertiesFile = Get-Item -Path $CustomizationFilePath
            $json.customizationFileName = $propertiesFile.Name
            $form.propertiesFile = $propertiesFile
        }
        $form.json = $json | ConvertTo-Json
        $apiEndpoint = Get-APNApiEndpoint -ApiType 'inspections'
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