function New-PackageInstallNotification {
    [CmdletBinding()]
    
    $CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $IsNonInteractiveShell = Test-IsNonInteractiveShell

    $ScriptBlock = {
        $HeroImage = Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx\media\heroimage\heroimage_modified.jpg'
        $AppLogo = Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx\media\icon\icon.png'
        $Text1 = 'Your System is Processing Updates'
        $Text2 = 'Do Not Turn Off Your Computer'
        $Text3 = ''
        $DismissButton = New-BTButton -Dismiss
        $Header = New-BTHeader -Title 'cChocoEx - Software Updates'
        $ProgressBar = New-BTProgressBar -Status 'Updating' -Indeterminate

        $ToastSplat = @{
            Text             = ($Text1, $Text2, $Text3)
            HeroImage        = $HeroImage
            AppLogo          = $AppLogo
            SnoozeAndDismiss = $true
            UniqueIdentifier = 'cChocoExToast01'
            Header           = $Header
            ProgressBar      = $ProgressBar
        }

        New-BurntToastNotification @ToastSplat
    }
    
    try {
        if ($CurrentUser -eq 'NT AUTHORITY\SYSTEM') {
            $null = Invoke-AsCurrentUser -ScriptBlock $ScriptBlock -NonElevatedSession
        }
        else {
            Invoke-Command $ScriptBlock
        }
    }
    catch {
        Write-Log -Severity 'Error' -Message "Failed to Create Toast Notification"
        Write-Log -Severity 'Error' -Message "$($_.Exception.Message)"
    }
}