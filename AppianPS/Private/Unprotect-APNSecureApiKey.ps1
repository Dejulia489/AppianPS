Function Unprotect-APNSecureApiKey {
    <#
    .SYNOPSIS

    Returns decrypted personal access token.

    .DESCRIPTION

    Returns decrypted personal access token that is stored in the session data.

    .PARAMETER ApiKey

    Personal access token used to authenticate that has been converted to a secure string. 
    It is recomended to uses an Azure Pipelines PS session to pass the personal access token parameter among funcitons, See New-APNSession.
    https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts
        
    .OUTPUTS

    String, unsecure personal access token.

    .EXAMPLE

    Unprotects the personal access token from secure string to plain text.

    Unprotect-SecureApiKey -ApiKey $mySecureToken

    .LINK

    https://docs.microsoft.com/en-us/azure/devops/integrate/get-started/authentication/authentication-guidance?view=vsts
    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [Security.SecureString]
        $ApiKey
    )
    Process {
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ApiKey)
        $plainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

        if ([environment]::OSVersion.Platform -eq "Unix") {
            $plainText = [System.Net.NetworkCredential]::new("", $ApiKey).Password
        }

        return $plainText
    }
}
