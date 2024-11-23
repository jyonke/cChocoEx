# New-EncryptedCredential

## SYNOPSIS
Creates an AES encrypted private/public key pair.

## DESCRIPTION
The `New-EncryptedCredential` function creates an AES encrypted private/public key pair to be used with cChocoEx. It generates a key file for decryption and a secure string file for the encrypted password.

## SYNTAX

```powershell
New-EncryptedCredential -Path <String> -Password <String>
```

## PARAMETERS

### -Path
Specifies the path for the export location of the key and password files.

```powershell
Type: String
Parameter Sets: (All)
Required: True
```

### -Password
Specifies the password to be encrypted.

```powershell
Type: String
Parameter Sets: (All)
Required: True
```

## EXAMPLES

### Example 1: Create encrypted credentials
```powershell
New-EncryptedCredential -Path 'C:\ProgramData\cChocoEx' -Password 'MySecretPassword'
```

Creates an AES encrypted key and password file at the specified path.

## OUTPUTS

### Files
- `AES.key`: The private key file used for decryption.
- `PS_SecureString.txt`: The public encrypted password.

## NOTES
- The function generates a random AES key for encryption.
- The key file and the encrypted password file are saved in the specified path.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 