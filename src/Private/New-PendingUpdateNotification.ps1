function New-PendingUpdateNotification {
    [CmdletBinding()]
    param (
        # Maintenance Window Start Time
        [Parameter(Mandatory = $true)]
        [string]
        $Start,
        # Maintenance End Time
        [Parameter(Mandatory = $true)]
        [string]
        $End,
        # Maintenance Window UTC
        [Parameter(Mandatory = $true)]
        [bool]
        $UTC
    )

    $CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $IsNonInteractiveShell = Test-IsNonInteractiveShell

    if ($UTC) {
        $StartTime = (ConvertTo-LocalTime -Time $Start -TimeZone 'UTC').ToShortTimeString()
        $EndTime = (ConvertTo-LocalTime -Time $End -TimeZone 'UTC').ToShortTimeString()
    }
    else {
        $StartTime = (Get-Date $Start).ToShortTimeString()
        $EndTime = (Get-Date $End).ToShortTimeString()
    }

    $ScriptBlockString = @"
    `$HeroImage = Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx\media\heroimage\heroimage_modified.jpg'
    `$AppLogo = Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx\media\icon\icon.png'
    `$Text1 = 'Please Ensure Your PC Stays On To Receive Important Updates'
    `$Text2 = 'Maintenance Window'
    `$Text3 = "Start Time: $($StartTime)`r`nEnd Time: $($EndTime)"
    `$DismissButton = New-BTButton -Dismiss
    `$Header = New-BTHeader -Title 'cChocoEx - Pending Updates'

    `$ToastSplat = @{
        Text             = (`$Text1, `$Text2, `$Text3)
        HeroImage        = `$HeroImage
        AppLogo          = `$AppLogo
        SnoozeAndDismiss = `$true
        UniqueIdentifier = 'cChocoExToast02'
        Header           = `$Header
    }

    New-BurntToastNotification @ToastSplat
"@

    $UpdatePromptScriptBlock = @"
    `$HeroImage = New-BTImage -HeroImage  -Source (Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx\media\heroimage\heroimage_modified.jpg')
    `$AppLogo = New-BTImage -AppLogoOverride -Source (Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx\media\icon\icon.png')
    `$Text1 = New-BTText -Text 'Please Ensure Your PC Stays On To Receive Important Updates'
    `$Text2 = New-BTText -Text 'Maintenance Window'
    `$Text3 = New-BTText -Text "Start Time: $($StartTime)`r`nEnd Time: $($EndTime)"
    `$Header = New-BTHeader -Title 'cChocoEx - Pending Updates'
    `$Button = New-BTButton -Content "Install Now" -Arguments "cChocoExUpdate:" -ActivationType Protocol
    `$Button2 = New-BTButton -Content "Snooze" -Snooze -Id 'SnoozeTime'
    `$Button3 = New-BTButton -Content 'Dismiss' -Dismiss
    `$5Min = New-BTSelectionBoxItem -Id 5 -Content '5 minutes'
    `$10Min = New-BTSelectionBoxItem -Id 10 -Content '10 minutes'
    `$1Hour = New-BTSelectionBoxItem -Id 60 -Content '1 hour'
    `$4Hour = New-BTSelectionBoxItem -Id 240 -Content '4 hours'
    `$1Day = New-BTSelectionBoxItem -Id 1440 -Content '1 day'
    `$Items = `$5Min, `$10Min, `$1Hour, `$4Hour, `$1Day
    `$SelectionBox = New-BTInput -Id 'SnoozeTime' -DefaultSelectionBoxItemId 10 -Items `$Items
    `$Action = New-BTAction -Buttons `$Button, `$Button2, `$Button3 -Inputs `$SelectionBox
    `$Binding = New-BTBinding -Children `$text1, `$text2, `$text3 -HeroImage `$HeroImage -AppLogoOverride `$AppLogo
    `$Visual = New-BTVisual -BindingGeneric `$Binding
    `$Content = New-BTContent -Visual `$Visual -Actions `$Action -Header `$Header

    `$ToastSplat = @{
        UniqueIdentifier = 'cChocoExToast02'
        Content          = `$Content
    }

    Submit-BTNotification @ToastSplat
"@
    $ScriptBlock = [scriptblock]::Create($UpdatePromptScriptBlock)

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