function Get-AutoPilotStatus {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        #https://www.reddit.com/r/Intune/comments/q8v92z/make_a_powershell_script_determine_if_it_is/
        [bool]$DevicePrepComplete = $false
        [bool]$DeviceSetupComplete = $false
        [bool]$AccountSetupComplete = $false
        [string]$AutoPilotSettingsKey = 'HKLM:\SOFTWARE\Microsoft\Provisioning\AutopilotSettings'
        [string]$DevicePrepName = 'DevicePreparationCategory.Status'
        [string]$DeviceSetupName = 'DeviceSetupCategory.Status'
        [string]$AccountSetupName = 'AccountSetupCategory.Status'
        [string]$AutoPilotDiagnosticsKey = 'HKLM:\SOFTWARE\Microsoft\Provisioning\Diagnostics\AutoPilot'
        [string]$TenantIdName = 'CloudAssignedTenantId'
        [string]$JoinInfoKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\JoinInfo'
        [string]$CloudAssignedTenantID = (Get-ItemProperty -Path $AutoPilotDiagnosticsKey -Name $TenantIdName -ErrorAction 'Ignore').$TenantIdName
    }
    
    process {
        if (-not [string]::IsNullOrEmpty($CloudAssignedTenantID)) {
            foreach ($Guid in (Get-ChildItem -Path $JoinInfoKey -ErrorAction 'Ignore')) {
                [string]$AzureADTenantId = (Get-ItemProperty -Path "$JoinInfoKey\$($Guid.PSChildName)" -Name 'TenantId' -ErrorAction 'Ignore').'TenantId'
            }

            if ($CloudAssignedTenantID -eq $AzureADTenantId) {
                $DevicePrepDetails = (Get-ItemProperty -Path $AutoPilotSettingsKey -Name $DevicePrepName -ErrorAction 'Ignore').$DevicePrepName
                $DeviceSetupDetails = (Get-ItemProperty -Path $AutoPilotSettingsKey -Name $DeviceSetupName -ErrorAction 'Ignore').$DeviceSetupName
                $AccountSetupDetails = (Get-ItemProperty -Path $AutoPilotSettingsKey -Name $AccountSetupName -ErrorAction 'Ignore').$AccountSetupName

                if (-not [string]::IsNullOrEmpty($DevicePrepDetails)) {
                    $DevicePrepDetails = $DevicePrepDetails | ConvertFrom-Json
                }
                if (-not [string]::IsNullOrEmpty($DeviceSetupDetails)) {
                    $DeviceSetupDetails = $DeviceSetupDetails | ConvertFrom-Json
                }
                if (-not [string]::IsNullOrEmpty($AccountSetupDetails)) {
                    $AccountSetupDetails = $AccountSetupDetails | ConvertFrom-Json
                }

                if (($DevicePrepDetails.categorySucceeded -eq 'True') -or ($DevicePrepDetails.categoryState -eq 'succeeded')) {
                    $DevicePrepComplete = $true
                }
                if (($DeviceSetupDetails.categorySucceeded -eq 'True') -or ($DeviceSetupDetails.categoryState -eq 'succeeded')) {
                    $DeviceSetupComplete = $true
                }
                if (($AccountSetupDetails.categorySucceeded -eq 'True') -or ($AccountSetupDetails.categoryState -eq 'succeeded')) {
                    $AccountSetupComplete = $true
                }

                if ($DevicePrepComplete -and $DeviceSetupComplete -and $AccountSetupComplete) {
                    $ESPComplete = $true
                }
                else {
                    $ESPComplete = $false
                }
            }
            else {
                $ESPComplete = $true
            }
        }
        else {
            $ESPComplete = $true
        }
    }
    
    end {
        $Object = [PSCustomObject]@{
            DevicePrepComplete   = $DevicePrepComplete
            DeviceSetupComplete  = $DeviceSetupComplete
            AccountSetupComplete = $AccountSetupComplete
            Complete             = $ESPComplete
        }
        return $Object
    }
}