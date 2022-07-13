function Set-RegistryConfiguration {
    $Path = "HKLM:\Software\cChocoEx\"

    #Ensure Running as Administrator
    if (-Not (Test-IsAdmin)) {
        Write-Warning "This function requires elevated access, please reopen PowerShell as an Administrator"
        Break
    }
    
    #Ensure Path is Created
    if (-not(Test-Path $Path)) {
        $null = New-Item -ItemType Directory -Path $Path -Force
    }

    #Reset User OverRideMaintenanceWindow Reg Key
    $null = Set-ItemProperty -Path $Path -Name 'OverRideMaintenanceWindow' -Value 0

    #Enable Standard User Accounts Write Access to Keys
    $Acl = Get-Acl -Path $Path
    $Account = [System.Security.Principal.NTAccount]"BuiltIn\Users"          
    $Access = [System.Security.AccessControl.RegistryRights]"WriteKey"
    $Inheritance = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit"
    $Propagation = [System.Security.AccessControl.PropagationFlags]"None"
    $Type = [System.Security.AccessControl.AccessControlType]"Allow"
    $Rule = New-Object System.Security.AccessControl.RegistryAccessRule($Account, $Access, $Inheritance, $Propagation, $Type)
    $Acl.AddAccessRule($Rule)
    $Acl | Set-Acl

    #Checking if cChocoExUpdate:// protocol handler is present
    #https://www.cyberdrain.com/monitoring-with-powershell-notifying-users-of-windows-updates/
    $null = New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ErrorAction Silentlycontinue
    $ProtocolHandler = Get-Item 'HKCR:\cChocoExUpdate' -ErrorAction 'SilentlyContinue'
    if (!$ProtocolHandler) {
        #Create Handler for Update
        $null = New-Item 'HKCR:\cChocoExUpdate' -Force
        $null = Set-ItemProperty 'HKCR:\cChocoExUpdate' -Name '(DEFAULT)' -Value 'url:cChocoExUpdate' -Force
        $null = Set-ItemProperty 'HKCR:\cChocoExUpdate' -Name 'URL Protocol' -Value '' -Force
        $null = New-ItemProperty -Path 'HKCR:\cChocoExUpdate' -PropertyType 'DWord' -Name 'EditFlags' -Value 2162688
        $null = New-Item 'HKCR:\cChocoExUpdate\Shell\Open\command' -Force
        $null = Set-ItemProperty 'HKCR:\cChocoExUpdate\Shell\Open\command' -Name '(DEFAULT)' -Value 'C:\Windows\System32\reg.exe add HKLM\Software\cChocoEx /v OverRideMaintenanceWindow /t REG_DWORD /d 1 /f' -Force
    }

    #Checking if ToastReboot:// protocol handler is present
    #https://www.cyberdrain.com/monitoring-with-powershell-notifying-users-of-windows-updates/
    $null = New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ErrorAction Silentlycontinue
    $ProtocolHandler = Get-Item 'HKCR:\ToastReboot' -ErrorAction 'SilentlyContinue'
    if (!$ProtocolHandler) {
        #Create Handler for Reboot
        $null = New-Item 'HKCR:\ToastReboot' -Force
        $null = Set-ItemProperty 'HKCR:\ToastReboot' -Name '(DEFAULT)' -Value 'url:ToastReboot' -Force
        $null = Set-ItemProperty 'HKCR:\ToastReboot' -Name 'URL Protocol' -Value '' -Force
        $null = New-ItemProperty -Path 'HKCR:\ToastReboot' -PropertyType 'DWord' -Name 'EditFlags' -Value 2162688
        $null = New-Item 'HKCR:\ToastReboot\Shell\Open\command' -Force
        $null = Set-ItemProperty 'HKCR:\ToastReboot\Shell\Open\command' -Name '(DEFAULT)' -Value 'C:\Windows\System32\shutdown.exe -r -t 00' -Force
    }
}