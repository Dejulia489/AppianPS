function Invoke-APNRestMethod {
    <#
    .SYNOPSIS

    Invokes an Appian rest method.

    .DESCRIPTION

    Invokes an Appian rest method.

    .PARAMETER Method

    Specifies the method used for the web request.

    .PARAMETER Body

    Specifies the body of the request. The body is the content of the request that follows the headers.

    .PARAMETER Form

    Converts a dictionary to a multipart/form-data submission. Form may not be used with Body. If ContentType is used, it's ignored.

    .PARAMETER ContentType

    Specifies the content type of the web request. If this parameter is omitted and the request method is POST, Invoke-RestMethod sets the content type to application/x-www-form-urlencoded. Otherwise, the content type is not specified in the call.

    .PARAMETER Uri

    Specifies the Uniform Resource Identifier (URI) of the Internet resource to which the web request is sent. This parameter supports HTTP, HTTPS, FTP, and FILE values.

    .PARAMETER ApiKey

    The Appian api key. The API key can be created in the Appian Administration Console, and then configured to secure external deployments.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .PARAMETER Proxy

    Use a proxy server for the request, rather than connecting directly to the Internet resource. Enter the URI of a network proxy server.

    .PARAMETER ProxyCredential

    Specifie a user account that has permission to use the proxy server that is specified by the -Proxy parameter. The default is the current user.

    .PARAMETER Path

    The directory to output files to.

    .PARAMETER Infile

    The fullname/path to the file that will be uploaded.

    .OUTPUTS

    System.Int64, System.String, System.Xml.XmlDocument, The output of the cmdlet depends upon the format of the content that is retrieved.

    .OUTPUTS

    PSObject, If the request returns JSON strings, Invoke-RestMethod returns a PSObject that represents the strings.

    .EXAMPLE

    NA

    .LINK

    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-restmethod?view=powershell-6
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]
        $Method,

        [Parameter()]
        [object]
        $Body,

        [Parameter()]
        [object]
        $Form,

        [Parameter(Mandatory)]
        [uri]
        $Uri,

        [Parameter()]
        [string]
        $ContentType,

        [Parameter()]
        [Security.SecureString]
        $ApiKey,

        [Parameter()]
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
        $Path,

        [Parameter()]
        [string]
        $InFile
    )

    begin {
    }

    process {
        $invokeRestMethodSplat = @{
            Method          = $Method
            Uri             = $uri.AbsoluteUri
        }
        If ($Body) {
            $invokeRestMethodSplat.ContentType = $ContentType
        }
        If ($Body) {
            $invokeRestMethodSplat.Body = ConvertTo-Json -InputObject $Body -Depth 20
        }
        If ($Form) {
            $invokeRestMethodSplat.Form = $Form
        }
        If ($Proxy) {
            $invokeRestMethodSplat.Proxy = $Proxy
            If ($ProxyCredential) {
                $invokeRestMethodSplat.ProxyCredential = $ProxyCredential
            }
            else {
                $invokeRestMethodSplat.ProxyUseDefaultCredentials = $true
            }
        }
        If ($Path) {
            $invokeRestMethodSplat.OutFile = $Path
        }
        If ($InFile) {
            $invokeRestMethodSplat.InFile = $InFile
        }
        $authenticatedRestMethodSplat = Set-APNAuthenticationType -InputObject $invokeRestMethodSplat -Credential $Credential -ApiKey $ApiKey
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Invoking $($uri.AbsoluteUri)"
        return Invoke-RestMethod @authenticatedRestMethodSplat
    }

    end {
    }
}
