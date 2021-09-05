<#
.SYNOPSIS
Creates an AES encrypted private/public key pair.
.DESCRIPTION
Creates an AES encrypted private/public key pair to be used with cChocoEx.
.OUTPUTS
AES.key - The private keyfile used for decryption.
PS_SecureString.txt - The public encrypted password.
#>
function New-EncryptedCredential {
    param (
        # Path for export location
        [Parameter(Mandatory=$true)]
        [string]
        $Path,
        # Password
        [Parameter(Mandatory=$true)]
        [string]
        $Password
    )
    $Key = New-Object Byte[] 32   # You can use 16, 24, or 32 for AES
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
    $Key | Out-File "$Path\AES.key"

    $PasswordFile = "$Path\PS_SecureString.txt"
    $KeyFile = "$Path\AES.key"
    $Key = Get-Content $KeyFile
    $SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
    $SecurePassword | ConvertFrom-SecureString -key $Key | Out-File $PasswordFile
}