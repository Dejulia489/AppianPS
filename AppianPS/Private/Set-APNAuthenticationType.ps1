function Set-APNAuthenticationType { 
    <#
    .SYNOPSIS

    Sets the authentication type used by Invoke-APRestMethod.

    .DESCRIPTION

    Sets the authentication type used by Invoke-APRestMethod.
    Default authentication will use the pesonal access token that is stored in session data, unless a credential is provided.

    .PARAMETER InputObject
    
    The splat parameters used by Invoke-APRestMethod.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.
    
    .OUTPUTS

    PSObject, The modifed inputobject.

    .EXAMPLE

    Set-APAuthenticationType -InputObject $inputObject

    .EXAMPLE

    Sets the AP authentication to the credential provided for the input object.

    Set-APNAuthenticationType -InputObject $inputObject -Credential $pscredential

    .EXAMPLE

    Sets the AP authentication to the personal access token provided for the input object.
    
    Set-APNAuthenticationType -InputObject $inputObject -ApiKey $mySecureToken

    .LINK

    https://docs.microsoft.com/en-us/azure/devops/integrate/get-started/authentication/authentication-guidance?view=vsts
    #>
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory)]
        [PSObject]
        $InputObject,

        [Parameter()]
        [Security.SecureString]
        $ApiKey,

        [Parameter()]
        [pscredential]
        $Credential
    )

    begin {
    }

    process {
        If ($Credential) {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Authenticating with the provided credential."
            $InputObject.Credential = $Credential
        }
        elseIf ($ApiKey) {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Authenticating with the stored api key."
            $apiKeyToken = Unprotect-APNSecureApiKey -ApiKey $ApiKey
            $InputObject.Headers = @{'Appian-API-Key' = $apiKeyToken }
        }
        else {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Authenticating with default credentials"
            $InputObject.UseDefaultCredentials = $true
        }
    }

    end {
        return $InputObject
    }
}
