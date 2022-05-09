function Invoke-APNPackageInspection {
    <#
    .SYNOPSIS

    Starts the Appian package inspection process.

    .DESCRIPTION

    Starts the Appian package inspection process by running the following commands.
        1. New-APNPackageInspection - Creates a package inspection request
        2. Get-APNInspectionResults - Waits for the inspection results, then returns the summary
        3. ConvertTo-APNMarkdownTable - Converts the summary to a markdown table and writes it to file.

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

    .PARAMETER OutputFormat

    Format to use when outputing the inspection results. PSObject or Markdown. Defaults to PSObject.

    .PARAMETER OutputPath

    The file path to write the summary report to. Only used when OutputFormat is set to Markdown.

    .PARAMETER Wait

    Flag to wait for summary status to not be 'In Progress'.

    .PARAMETER TimeoutSeconds

    The number of seconds to wait before timing out. Defaults to 120.

    .PARAMETER SleepSeconds

    The number of seconds to sleep inbetween requests. Defaults to 1.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject, Appian inspection object

    .EXAMPLE

    Invokes the Appian package inspection process.

    $splat = @{
        Session               = 'mySession'
        PackageFilePath       = ".\myZipPackage.zip"
        CustomizationFilePath = '.\DEV.properties'
        OutputFormat          = 'Markdown'
        OutputPath            = '.\Report.md'
        Verbose               = $true
    }
    Invoke-APNPackageInspection @splat

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
        $CustomizationFilePath,

        [Parameter()]
        [ValidateSet('PSObject', 'Markdown')]
        [string]
        $OutputFormat = 'PSObject',

        [Parameter()]
        [string]
        $OutputPath,

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
        $splat = @{
            Domain          = $Domain
            Proxy           = $Proxy
            ProxyCredential = $ProxyCredential
        }
        If ($ApiKey) {
            $splat.ApiKey = $ApiKey
        }
        If ($Credential) {
            $splat.Credential = $Credential
        }
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Invoking New-APNPackageInspection"
        $results = New-APNPackageInspection @splat -PackageFilePath $PackageFilePath -CustomizationFilePath $CustomizationFilePath
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Invoking Get-APNInspectionResults"
        $report = Get-APNInspectionResults @splat -InspectionId $results.UUID -Wait $true
        If ($OutputFormat -eq 'Markdown') {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Invoking ConvertTo-APNMarkdownInspectionReport"
            $formattedReport = ConvertTo-APNMarkdownInspectionReport -InputObject $report
            If ($OutputPath) {
                $formattedReport | Out-File $OutputPath
            }
        }
        return @{
            report = $report
            UUID   = $results.UUID
        }
   
    }

    end {
    }
}