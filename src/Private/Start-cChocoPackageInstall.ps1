function Start-cChocoPackageInstall {
    [CmdletBinding()]
    param (
        [Parameter()]
        [array]
        $Configurations
    )

    $ActiveToast = $false
    Write-Log -Severity "Information" -Message "cChocoPackageInstall:Validating Chocolatey Packages are Setup"

    #Evaluate Ring Status
    $Ring = Get-cChocoExRing
    Write-Log -Severity 'Information' -Message "Local Machine Deployment Ring: $Ring"
    
    #Get Environment Restriction Status
    $OOBEStatsu = Test-IsWinOS.OOBE
    $TSStatus = Test-TSEnv
    $VPNStatus = Get-VPN -Active

    #Validate No Duplicate Package/Rings
    $PSCustomObject = $Configurations | ForEach-Object {
        if (-Not($_.Ring)) {
            $_.Ring -eq 'Broad'
        }
        [PSCustomObject]@{
            Name = $_.Name
            Ring = $_.Ring
        }
    }
    $Duplicates = $PSCustomObject | Group-Object -Property Name, Ring | Where-Object { $_.Count -gt 1 } 
    
    if ($Duplicates.Count -gt 0) {
        Write-Log -Severity 'Warning' -Message "Duplicate cChocoPackageInstall"
        Write-Log -Severity 'Warning' -Message "Duplicate Package Found removing from active processesing"
        $Configurations | Where-Object { $Duplicates.Group.Name -eq $_.Name } | ForEach-Object {
            Write-Log -Severity 'Warning' -Message "Name: $($_.Name)"
            Write-Log -Severity 'Warning' -Message "Version $($_.Version)"
            Write-Log -Severity 'Warning' -Message "MinimumVersion $($_.MinimumVersion)"
            Write-Log -Severity 'Warning' -Message "DSC: $($_.DSC)"
            Write-Log -Severity 'Warning' -Message "Source: $($_.Source)"
            Write-Log -Severity 'Warning' -Message "Ensure: $($_.Ensure)"
            Write-Log -Severity 'Warning' -Message "AutoUpgrade: $($_.AutoUpgrade)"
            Write-Log -Severity 'Warning' -Message "VPN: $($_.VPN)"
            Write-Log -Severity 'Warning' -Message "Params: $($_.Params)"
            Write-Log -Severity 'Warning' -Message "ChocoParams: $($_.ChocoParams)"
            Write-Log -Severity 'Warning' -Message "Ring: $($_.Ring)"
            Write-Log -Severity 'Warning' -Message "Priority: $($_.Priority)"
            Write-Log -Severity 'Warning' -Message "OverrideMaintenanceWindow: $($_.OverrideMaintenanceWindow)"
            Write-Log -Severity 'Warning' -Message "EnvRestriction: $($_.EnvRestriction)"
            Write-Log -Severity 'Warning' -Message "Duplicate Package Defined"
        }
        #Filter Out Duplicates and Clear all package configuration files for next time processing
        Write-Log -Severity 'Warning' -Message "Filter Out Duplicates and Clear all package configuration files for next time processing"
        $Configurations = $Configurations | Where-Object { $Duplicates.Group.Name -notcontains $_.Name }
        Get-ChildItem -Path $PackageConfigDestination -Filter *.psd1 | Where-Object { $_.Name -notmatch "sources.psd1|config.psd1|features.psd1" } | Remove-Item -Force -ErrorAction SilentlyContinue
    }

    #Filter and Validate Packages with defined deploymentrings
    Write-Log -Severity 'Information' -Message "Getting Valid Deployment Ring Packages"
    $PriorityConfigurations = Get-PackagePriority -Configurations $Configurations
      
    $i = 0
    $Status = @()
    $ModulePath = (Join-Path $ModuleBase "cChocoPackageInstall")
    Write-Log -Severity "Information" -Message "Starting cChocoPackageInstall"
    $PriorityConfigurations | ForEach-Object {
        Import-Module $ModulePath
        $DSC = $null
        $Configuration = $_
        $Object = [PSCustomObject]@{
            Name                      = $Configuration.Name
            DSC                       = $null
            Version                   = $Configuration.Version
            MinimumVersion            = $Configuration.MinimumVersion
            Ensure                    = $Configuration.Ensure
            Source                    = $Configuration.Source
            AutoUpgrade               = $Configuration.AutoUpgrade
            VPN                       = $Configuration.VPN
            Params                    = $Configuration.Params
            ChocoParams               = $Configuration.ChocoParams
            Ring                      = $Configuration.Ring
            Priority                  = $Configuration.Priority
            OverrideMaintenanceWindow = $Configuration.OverrideMaintenanceWindow
            EnvRestriction            = $Configuration.EnvRestriction
            Warning                   = $null
        }

        #Write Progress to Console
        if ($Configuration.Version) {
            $StatusMessage = "$($Configuration.Name) - $($Configuration.Version)"
        }
        elseif ($Configuration.MinimumVersion) {
            $StatusMessage = "$($Configuration.Name) - $($Configuration.MinimumVersion)"
        }
        else {
            $StatusMessage = "$($Configuration.Name)"
        }
        Write-Progress -Activity "cChocoPackageInstall - $i/$(($PriorityConfigurations | Measure-Object).Count)" -Status $StatusMessage -PercentComplete ( ( $i / ($PriorityConfigurations | Measure-Object).Count ) * 100 )
        $i++

        #Evaluate Maintenance Window
        Start-cChocoConfig.MaintWindow -ConfigImport $Global:ChocoConfigDestination
        
        #Evaluate VPN Restrictions
        if ($null -ne $Configuration.VPN) {
            if ($Configuration.VPN -eq $false -and $VPNStatus) {
                $Configuration.Remove("VPN")
                $Configuration.Remove("Ring")
                $Configuration.Remove("OverrideMaintenanceWindow")
                $Configuration.Remove("Priority")
                $Configuration.Remove("EnvRestriction")
                $Object.Warning = "Configuration restricted when VPN is connected"
                $DSC = Test-TargetResource @Configuration
                $Object.DSC = $DSC
                $Status += $Object    
                #Remove Module for Write-Host limitations
                Remove-Module "cChocoPackageInstall"

                Write-Host "----------cChocoPackageInstall $i/$(($PriorityConfigurations | Measure-Object).Count)-------" -ForegroundColor DarkCyan
                Write-Log -Severity 'Information' -Message "Name: $($Object.Name)"
                Write-Log -Severity 'Information' -Message "DSC: $($Object.DSC)"
                Write-Log -Severity 'Information' -Message "Version $($Object.Version)"
                Write-Log -Severity 'Information' -Message "MinimumVersion $($_.MinimumVersion)"
                Write-Log -Severity 'Information' -Message "Source: $($Object.Source)"
                Write-Log -Severity 'Information' -Message "Ensure: $($Object.Ensure)"
                Write-Log -Severity 'Information' -Message "AutoUpgrade: $($Object.AutoUpgrade)"
                Write-Log -Severity 'Information' -Message "VPN: $($Object.VPN)"
                Write-Log -Severity 'Information' -Message "Params: $($Object.Params)"
                Write-Log -Severity 'Information' -Message "ChocoParams: $($Object.ChocoParams)"
                Write-Log -Severity 'Information' -Message "Ring: $($Object.Ring)"
                Write-Log -Severity 'Information' -Message "Priority: $($Object.Priority)"
                Write-Log -Severity 'Information' -Message "OverrideMaintenanceWindow: $($Object.OverrideMaintenanceWindow)"
                if ($Object.Warning) {
                    Write-Log -Severity Warning -Message "$($Object.Warning)"
                }    
                return
            }
            if ($Configuration.VPN -eq $true -and -not($VPNStatus)) {
                $Configuration.Remove("VPN")
                $Configuration.Remove("Ring")
                $Configuration.Remove("OverrideMaintenanceWindow")
                $Configuration.Remove("Priority")
                $Configuration.Remove("EnvRestriction")
                $Object.Warning = "Configuration restricted when VPN is not established"
                $DSC = Test-TargetResource @Configuration
                $Object.DSC = $DSC
                $Status += $Object
                #Remove Module for Write-Host limitations
                Remove-Module "cChocoPackageInstall"

                Write-Host "----------cChocoPackageInstall $i/$(($PriorityConfigurations | Measure-Object).Count)-------" -ForegroundColor DarkCyan
                Write-Log -Severity 'Information' -Message "Name: $($Object.Name)"
                Write-Log -Severity 'Information' -Message "DSC: $($Object.DSC)"
                Write-Log -Severity 'Information' -Message "Version $($Object.Version)"
                Write-Log -Severity 'Information' -Message "MinimumVersion $($_.MinimumVersion)"
                Write-Log -Severity 'Information' -Message "Source: $($Object.Source)"
                Write-Log -Severity 'Information' -Message "Ensure: $($Object.Ensure)"
                Write-Log -Severity 'Information' -Message "AutoUpgrade: $($Object.AutoUpgrade)"
                Write-Log -Severity 'Information' -Message "VPN: $($Object.VPN)"
                Write-Log -Severity 'Information' -Message "Params: $($Object.Params)"
                Write-Log -Severity 'Information' -Message "ChocoParams: $($Object.ChocoParams)"
                Write-Log -Severity 'Information' -Message "Ring: $($Object.Ring)"
                Write-Log -Severity 'Information' -Message "Priority: $($Object.Priority)"
                Write-Log -Severity 'Information' -Message "OverrideMaintenanceWindow: $($Object.OverrideMaintenanceWindow)"
                if ($Object.Warning) {
                    Write-Log -Severity Warning -Message "$($Object.Warning)"
                }
                return
            }
            $Configuration.Remove("VPN")
        }
        #Evaluate Ring Restrictions
        if ($null -ne $Configuration.Ring) {
            $ConfigurationRingValue = Get-RingValue -Name $Configuration.Ring
            if ($Ring) {
                $SystemRingValue = Get-RingValue -Name $Ring
            }
            if ($SystemRingValue -lt $ConfigurationRingValue ) {
                $Object.Warning = "Configuration restricted to $($Configuration.Ring) ring. Current ring $Ring"
                $Configuration.Remove("Ring")
                $Configuration.Remove("OverrideMaintenanceWindow")
                $Configuration.Remove("VPN")
                $Configuration.Remove("Priority")
                $Configuration.Remove("EnvRestriction")
                $DSC = Test-TargetResource @Configuration
                $Object.DSC = $DSC
                $Status += $Object   
                #Remove Module for Write-Host limitations
                Remove-Module "cChocoPackageInstall"

                Write-Host "----------cChocoPackageInstall $i/$(($PriorityConfigurations | Measure-Object).Count)-------" -ForegroundColor DarkCyan
                Write-Log -Severity 'Information' -Message "Name: $($Object.Name)"
                Write-Log -Severity 'Information' -Message "DSC: $($Object.DSC)"
                Write-Log -Severity 'Information' -Message "Version $($Object.Version)"
                Write-Log -Severity 'Information' -Message "MinimumVersion $($_.MinimumVersion)"
                Write-Log -Severity 'Information' -Message "Source: $($Object.Source)"
                Write-Log -Severity 'Information' -Message "Ensure: $($Object.Ensure)"
                Write-Log -Severity 'Information' -Message "AutoUpgrade: $($Object.AutoUpgrade)"
                Write-Log -Severity 'Information' -Message "VPN: $($Object.VPN)"
                Write-Log -Severity 'Information' -Message "Params: $($Object.Params)"
                Write-Log -Severity 'Information' -Message "ChocoParams: $($Object.ChocoParams)"
                Write-Log -Severity 'Information' -Message "Ring: $($Object.Ring)"
                Write-Log -Severity 'Information' -Message "Priority: $($Object.Priority)"
                Write-Log -Severity 'Information' -Message "OverrideMaintenanceWindow: $($Object.OverrideMaintenanceWindow)"
                if ($Object.Warning) {
                    Write-Log -Severity Warning -Message "$($Object.Warning)"
                }     
                return
            }
            $Configuration.Remove("Ring")
        }
        #Evaluate Maintenance Window Restrictions
        if (($Configuration.OverrideMaintenanceWindow -ne $true) -and ($Global:OverrideMaintenanceWindow -ne $true)) {
            if (-not($Global:MaintenanceWindowEnabled -and $Global:MaintenanceWindowActive)) {
                $Object.Warning = "Configuration restricted to Maintenance Window"
                $Configuration.Remove("OverrideMaintenanceWindow")
                $Configuration.Remove("Ring")
                $Configuration.Remove("VPN")
                $Configuration.Remove("Priority")
                $Configuration.Remove("EnvRestriction")
                $DSC = Test-TargetResource @Configuration
                $Object.DSC = $DSC
                $Status += $Object   
                #Create Pending Update Notice
                if (($Global:EnableNotifications) -and (-not($DSC))) {
                    $UpdateToast = $true
                }
                #Remove Module for Write-Host limitations
                Remove-Module "cChocoPackageInstall"

                Write-Host "----------cChocoPackageInstall $i/$(($PriorityConfigurations | Measure-Object).Count)-------" -ForegroundColor DarkCyan
                Write-Log -Severity 'Information' -Message "Name: $($Object.Name)"
                Write-Log -Severity 'Information' -Message "DSC: $($Object.DSC)"
                Write-Log -Severity 'Information' -Message "Version $($Object.Version)"
                Write-Log -Severity 'Information' -Message "MinimumVersion $($_.MinimumVersion)"
                Write-Log -Severity 'Information' -Message "Source: $($Object.Source)"
                Write-Log -Severity 'Information' -Message "Ensure: $($Object.Ensure)"
                Write-Log -Severity 'Information' -Message "AutoUpgrade: $($Object.AutoUpgrade)"
                Write-Log -Severity 'Information' -Message "VPN: $($Object.VPN)"
                Write-Log -Severity 'Information' -Message "Params: $($Object.Params)"
                Write-Log -Severity 'Information' -Message "ChocoParams: $($Object.ChocoParams)"
                Write-Log -Severity 'Information' -Message "Ring: $($Object.Ring)"
                Write-Log -Severity 'Information' -Message "Priority: $($Object.Priority)"
                Write-Log -Severity 'Information' -Message "OverrideMaintenanceWindow: $($Object.OverrideMaintenanceWindow)"
                if ($Object.Warning) {
                    Write-Log -Severity Warning -Message "$($Object.Warning)"
                }
                return
            }
        }
        #Evaluate Environment Restrictions
        if ($Configuration.EnvRestriction) {
            if ($Configuration.EnvRestriction -match 'TS|TSEnv|TaskSequence|Task Sequence' -and $TSStatus) {
                $Object.Warning = "Task Sequence Environment detected configuration restricted "
                $Configuration.Remove("OverrideMaintenanceWindow")
                $Configuration.Remove("Ring")
                $Configuration.Remove("VPN")
                $Configuration.Remove("Priority")
                $Configuration.Remove("EnvRestriction")
                $DSC = Test-TargetResource @Configuration
                $Object.DSC = $DSC
                $Status += $Object   
                #Create Pending Update Notice
                if (($Global:EnableNotifications) -and (-not($DSC))) {
                    $UpdateToast = $true
                }
                #Remove Module for Write-Host limitations
                Remove-Module "cChocoPackageInstall"

                Write-Host "----------cChocoPackageInstall $i/$(($PriorityConfigurations | Measure-Object).Count)-------" -ForegroundColor DarkCyan
                Write-Log -Severity 'Information' -Message "Name: $($Object.Name)"
                Write-Log -Severity 'Information' -Message "DSC: $($Object.DSC)"
                Write-Log -Severity 'Information' -Message "Version $($Object.Version)"
                Write-Log -Severity 'Information' -Message "MinimumVersion $($_.MinimumVersion)"
                Write-Log -Severity 'Information' -Message "Source: $($Object.Source)"
                Write-Log -Severity 'Information' -Message "Ensure: $($Object.Ensure)"
                Write-Log -Severity 'Information' -Message "AutoUpgrade: $($Object.AutoUpgrade)"
                Write-Log -Severity 'Information' -Message "VPN: $($Object.VPN)"
                Write-Log -Severity 'Information' -Message "Params: $($Object.Params)"
                Write-Log -Severity 'Information' -Message "ChocoParams: $($Object.ChocoParams)"
                Write-Log -Severity 'Information' -Message "Ring: $($Object.Ring)"
                Write-Log -Severity 'Information' -Message "Priority: $($Object.Priority)"
                Write-Log -Severity 'Information' -Message "OverrideMaintenanceWindow: $($Object.OverrideMaintenanceWindow)"
                if ($Object.Warning) {
                    Write-Log -Severity Warning -Message "$($Object.Warning)"
                }
                return
            }
            if ($Configuration.EnvRestriction -match 'OOBE|ESP|Autopilot' -and $OOBEStatsu) {
                $Object.Warning = "OOBE Environment detected configuration restricted "
                $Configuration.Remove("OverrideMaintenanceWindow")
                $Configuration.Remove("Ring")
                $Configuration.Remove("VPN")
                $Configuration.Remove("Priority")
                $Configuration.Remove("EnvRestriction")
                $DSC = Test-TargetResource @Configuration
                $Object.DSC = $DSC
                $Status += $Object   
                #Create Pending Update Notice
                if (($Global:EnableNotifications) -and (-not($DSC))) {
                    $UpdateToast = $true
                }
                #Remove Module for Write-Host limitations
                Remove-Module "cChocoPackageInstall"

                Write-Host "----------cChocoPackageInstall $i/$(($PriorityConfigurations | Measure-Object).Count)-------" -ForegroundColor DarkCyan
                Write-Log -Severity 'Information' -Message "Name: $($Object.Name)"
                Write-Log -Severity 'Information' -Message "DSC: $($Object.DSC)"
                Write-Log -Severity 'Information' -Message "Version $($Object.Version)"
                Write-Log -Severity 'Information' -Message "MinimumVersion $($_.MinimumVersion)"
                Write-Log -Severity 'Information' -Message "Source: $($Object.Source)"
                Write-Log -Severity 'Information' -Message "Ensure: $($Object.Ensure)"
                Write-Log -Severity 'Information' -Message "AutoUpgrade: $($Object.AutoUpgrade)"
                Write-Log -Severity 'Information' -Message "VPN: $($Object.VPN)"
                Write-Log -Severity 'Information' -Message "Params: $($Object.Params)"
                Write-Log -Severity 'Information' -Message "ChocoParams: $($Object.ChocoParams)"
                Write-Log -Severity 'Information' -Message "Ring: $($Object.Ring)"
                Write-Log -Severity 'Information' -Message "Priority: $($Object.Priority)"
                Write-Log -Severity 'Information' -Message "OverrideMaintenanceWindow: $($Object.OverrideMaintenanceWindow)"
                if ($Object.Warning) {
                    Write-Log -Severity Warning -Message "$($Object.Warning)"
                }
                return
            }
            if ($Configuration.EnvRestriction -match 'VPN' -and $VPNStatus) {
                $Object.Warning = "Active VPN Environment detected configuration restricted "
                $Configuration.Remove("OverrideMaintenanceWindow")
                $Configuration.Remove("Ring")
                $Configuration.Remove("VPN")
                $Configuration.Remove("Priority")
                $Configuration.Remove("EnvRestriction")
                $DSC = Test-TargetResource @Configuration
                $Object.DSC = $DSC
                $Status += $Object   
                #Create Pending Update Notice
                if (($Global:EnableNotifications) -and (-not($DSC))) {
                    $UpdateToast = $true
                }
                #Remove Module for Write-Host limitations
                Remove-Module "cChocoPackageInstall"

                Write-Host "----------cChocoPackageInstall $i/$(($PriorityConfigurations | Measure-Object).Count)-------" -ForegroundColor DarkCyan
                Write-Log -Severity 'Information' -Message "Name: $($Object.Name)"
                Write-Log -Severity 'Information' -Message "DSC: $($Object.DSC)"
                Write-Log -Severity 'Information' -Message "Version $($Object.Version)"
                Write-Log -Severity 'Information' -Message "MinimumVersion $($_.MinimumVersion)"
                Write-Log -Severity 'Information' -Message "Source: $($Object.Source)"
                Write-Log -Severity 'Information' -Message "Ensure: $($Object.Ensure)"
                Write-Log -Severity 'Information' -Message "AutoUpgrade: $($Object.AutoUpgrade)"
                Write-Log -Severity 'Information' -Message "VPN: $($Object.VPN)"
                Write-Log -Severity 'Information' -Message "Params: $($Object.Params)"
                Write-Log -Severity 'Information' -Message "ChocoParams: $($Object.ChocoParams)"
                Write-Log -Severity 'Information' -Message "Ring: $($Object.Ring)"
                Write-Log -Severity 'Information' -Message "Priority: $($Object.Priority)"
                Write-Log -Severity 'Information' -Message "OverrideMaintenanceWindow: $($Object.OverrideMaintenanceWindow)"
                if ($Object.Warning) {
                    Write-Log -Severity Warning -Message "$($Object.Warning)"
                }
                return
            }
        }
        $Configuration.Remove("OverrideMaintenanceWindow")
        $Configuration.Remove("Priority")
        $Configuration.Remove("EnvRestriction")

        $DSC = Test-TargetResource @Configuration
        if (-not($DSC)) {
            #Create Active Update Notice
            if ((-not($ActiveToast)) -and $Global:EnableNotifications) {
                New-PackageInstallNotification
                $ActiveToast = $true
            }
            $null = Set-TargetResource @Configuration
            $DSC = Test-TargetResource @Configuration
        }
        $Object.DSC = $DSC
        $Status += $Object

        #Remove Module for Write-Host limitations
        Remove-Module "cChocoPackageInstall"

        Write-Host "----------cChocoPackageInstall $i/$(($PriorityConfigurations | Measure-Object).Count)-------" -ForegroundColor DarkCyan
        Write-Log -Severity 'Information' -Message "Name: $($Object.Name)"
        Write-Log -Severity 'Information' -Message "DSC: $($Object.DSC)"
        Write-Log -Severity 'Information' -Message "Version $($Object.Version)"
        Write-Log -Severity 'Information' -Message "MinimumVersion $($_.MinimumVersion)"
        Write-Log -Severity 'Information' -Message "Source: $($Object.Source)"
        Write-Log -Severity 'Information' -Message "Ensure: $($Object.Ensure)"
        Write-Log -Severity 'Information' -Message "AutoUpgrade: $($Object.AutoUpgrade)"
        Write-Log -Severity 'Information' -Message "VPN: $($Object.VPN)"
        Write-Log -Severity 'Information' -Message "Params: $($Object.Params)"
        Write-Log -Severity 'Information' -Message "ChocoParams: $($Object.ChocoParams)"
        Write-Log -Severity 'Information' -Message "Ring: $($Object.Ring)"
        Write-Log -Severity 'Information' -Message "Priority: $($Object.Priority)"
        Write-Log -Severity 'Information' -Message "OverrideMaintenanceWindow: $($Object.OverrideMaintenanceWindow)"
        if ($Object.Warning) {
            Write-Log -Severity Warning -Message "$($Object.Warning)"
        }
    }
    Write-Progress -Activity 'cChocoPackageInstall' -Completed
    Write-Host '----------cChocoPackageInstall----------' -ForegroundColor DarkCyan
    
    #Complete Active Toast Notification
    $PendingReboot = Test-PendingReboot -ErrorAction SilentlyContinue

    if ($Global:EnableNotifications -and $ActiveToast) {
        if ($PendingReboot) {
            Update-PackageInstallNotification -PendingReboot
        }
        else {
            Update-PackageInstallNotification
        }
    } 
    
    #Create Pending Update Toast
    if ($Global:EnableNotifications -and $UpdateToast) {
        $GetcChocoExMaintenanceWindow = Get-cChocoExMaintenanceWindow
        New-PendingUpdateNotification -Start $GetcChocoExMaintenanceWindow.Start -End $GetcChocoExMaintenanceWindow.End -UTC $GetcChocoExMaintenanceWindow.UTC
    }
}