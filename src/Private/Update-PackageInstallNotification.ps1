function Update-PackageInstallNotification {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $PendingReboot
    )
    
    $CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $IsNonInteractiveShell = Test-IsNonInteractiveShell
 
    $RebootScriptBlock = {
        $HeroImage = New-BTImage -HeroImage  -Source (Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx\media\heroimage\heroimage_modified.jpg')
        $AppLogo = New-BTImage -AppLogoOverride -Source (Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx\media\icon\icon.png')
        $Text1 = New-BTText -Text 'Updates Completed - Reboot Required'
        $Text2 = New-BTText -Text ''
        $Text3 = New-BTText -Text ''
        $Header = New-BTHeader -Title 'cChocoEx - Software Updates'
        $Button = New-BTButton -Content "Snooze" -Snooze -Id 'SnoozeTime'
        $Button2 = New-BTButton -Content "Reboot Now" -Arguments "ToastReboot:" -ActivationType Protocol
        $5Min = New-BTSelectionBoxItem -Id 5 -Content '5 minutes'
        $10Min = New-BTSelectionBoxItem -Id 10 -Content '10 minutes'
        $1Hour = New-BTSelectionBoxItem -Id 60 -Content '1 hour'
        $4Hour = New-BTSelectionBoxItem -Id 240 -Content '4 hours'
        $1Day = New-BTSelectionBoxItem -Id 1440 -Content '1 day'
        $Items = $5Min, $10Min, $1Hour, $4Hour, $1Day
        $SelectionBox = New-BTInput -Id 'SnoozeTime' -DefaultSelectionBoxItemId 10 -Items $Items
        $Action = New-BTAction -Buttons $Button, $Button2 -Inputs $SelectionBox
        $Binding = New-BTBinding -Children $text1, $text2, $text3 -HeroImage $HeroImage -AppLogoOverride $AppLogo
        $Visual = New-BTVisual -BindingGeneric $Binding
        $Content = New-BTContent -Visual $Visual -Actions $Action -Header $Header

        $ToastSplat = @{
            UniqueIdentifier = 'cChocoExToast01'
            Content          = $Content
        }

        Submit-BTNotification @ToastSplat
    }

    $StandardScriptBlock = {
        $HeroImage = Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx\media\heroimage\heroimage_modified.jpg'
        $AppLogo = Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx\media\icon\icon.png'
        $Text1 = 'Updates Completed'
        $Text2 = ''
        $Text3 = ''
        $DismissButton = New-BTButton -Dismiss
        $Header = New-BTHeader -Title 'cChocoEx - Software Updates'

        $ToastSplat = @{
            Text             = ($Text1, $Text2, $Text3)
            HeroImage        = $HeroImage
            AppLogo          = $AppLogo
            Button           = $DismissButton
            UniqueIdentifier = 'cChocoExToast01'
            Header           = $Header
        }

        New-BurntToastNotification @ToastSplat
    }

    if ($PendingReboot) {
        $ScriptBlock = $RebootScriptBlock
    }
    else {
        $ScriptBlock = $StandardScriptBlock
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