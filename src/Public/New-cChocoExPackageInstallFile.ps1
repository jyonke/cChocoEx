<#
.SYNOPSIS
Creates Chocolatey Packages DSC Configuration File for cChocoEx
.DESCRIPTION
Creates Chocolatey Packages DSC Configuration File for cChocoEx as a PowerShell Data File
#>
function New-cChocoExPackageInstallFile {
    [CmdletBinding()]
    param (
        # Path of Output File
        [Parameter(Mandatory)]
        [string]
        $Path,
        # NoClobber
        [Parameter()]
        [switch]
        $NoClobber
    )
    
    begin {
        $ExportString = "@{`n"
        $Absent = New-Object System.Management.Automation.Host.ChoiceDescription '&Absent'
        $Present = New-Object System.Management.Automation.Host.ChoiceDescription '&Present'
        $SelectTrue = New-Object System.Management.Automation.Host.ChoiceDescription '&True'
        $SelectFalse = New-Object System.Management.Automation.Host.ChoiceDescription '&False'
        $SelectYes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes'
        $SelectNo = New-Object System.Management.Automation.Host.ChoiceDescription '&No'
        $EnsureOptions = [System.Management.Automation.Host.ChoiceDescription[]]($Present, $Absent)
        $TrueFalseOptions = [System.Management.Automation.Host.ChoiceDescription[]]($SelectTrue, $SelectFalse)
        $YesNoOptions = [System.Management.Automation.Host.ChoiceDescription[]]($SelectYes, $SelectNo)
        $Title = 'cChocoEx - Desired State'
        $ReqChoices = @(
            'Name'
            'Ensure (Present/Absent)'
        )
        $Optchoices = @(
            'Version (Yes/No)'
            'MinimumVersion (Yes/No)'
            'AutoUpgrade ($True/$False)'
            'Source'
            'Params'
            'ChocoParams'
            'OverrideMaintenanceWindow ($True/$False)'
            'VPN ($True/$False)'
            'Ring'
        )

        #Ensure choco is installed
        try {
            $null = Get-Command choco.exe
        }
        catch {
            $_.Exception.Message
            Exit
        }
    }
    
    process {
        #Gather Sources
        $Sources = choco.exe sources -r | ConvertFrom-Csv -Delimiter '|' -Header Name, URL | Select-Object Name, URL
        $SelectedSource = $Sources | Out-GridView -Title 'Please Select Source to Pull Package Names from' -OutputMode Single
        Write-Verbose "SelectedSource Name: $($SelectedSource.Name)" 
        Write-Verbose "SelectedSource URL: $($SelectedSource.URL)" 

        do {
            $HashTable = $null
            $Search = $null
            $SelectedPackage = $null
            $HashTable = $host.ui.Prompt(($Title + " - PackageInstall"), $null, $Reqchoices)

            $Search = choco.exe search $($HashTable.Name) -r -pre -s $SelectedSource.Name --by-id-only | ConvertFrom-Csv -Delimiter '|' -Header Name, Version
            $SelectedPackage = $Search | Sort-Object -Property Name -Unique |Select-Object Name | Out-GridView -Title 'Please Select a Package' -OutputMode Single
            if ($null -eq $SelectedPackage) {
                Write-Verbose "No Package Selected"
                return
            }
            Write-Verbose "SelectedPackage Name: $($SelectedPackage.Name)" 

            $ExportString += "`t`'$($SelectedPackage.Name)`' = @{`n"
            $ExportString += "`t`tName`t`t= `'$($SelectedPackage.Name)`'`n"

            if ($HashTable.('Ensure (Present/Absent)') -eq 'Absent') {
                $ExportString += "`t`tEnsure`t`t= `'$($HashTable.('Ensure (Present/Absent)'))`'`n"
            }
            else {
                $HashTable.('Ensure (Present/Absent)') = 'Present'
                $ExportString += "`t`tEnsure`t`t= `'$($HashTable.('Ensure (Present/Absent)'))`'`n"

                #Options
                $HashTable += $host.ui.Prompt($null, $null, $Optchoices)
                if ($HashTable.('Version (Yes/No)') -like 'Y*') {
                    $Version = $null
                    $Search = choco.exe search $($SelectedPackage.Name) -r -pre -all -s $SelectedSource.Name --by-id-only | ConvertFrom-Csv -Delimiter '|' -Header Name, Version
                    $Version = ($Search | Where-Object { $_.Name -eq $($SelectedPackage.Name) } | Out-GridView -Title 'Please Select a Version' -OutputMode Single).Version
                    $ExportString += "`t`tVersion`t`t= `'$($Version)`'`n"
                    Write-Verbose "Version: $Version"
                }
                if ($HashTable.('MinimumVersion (Yes/No)') -like 'Y*') {
                    $MinVersion = $null
                    $Search = choco.exe search $($SelectedPackage.Name) -r -pre -all -s $SelectedSource.Name --by-id-only | ConvertFrom-Csv -Delimiter '|' -Header Name, Version
                    $MinVersion = ($Search | Where-Object { $_.Name -eq $($SelectedPackage.Name) } | Out-GridView -Title 'Please Select a MinimumVersion' -OutputMode Single).Version
                    $ExportString += "`t`tMinimumVersion`t= `'$($MinVersion)`'`n"
                    Write-Verbose "MinimumVersion: $MinVersion"
                }
                if ($HashTable.('AutoUpgrade ($True/$False)')) {
                    $ExportString += "`t`tAutoUpgrade`t= $($HashTable.('AutoUpgrade ($True/$False)'))`n"
                }
                if ($HashTable.Source) {
                    $ExportString += "`t`tSource`t`t= `'$($HashTable.Source)`'`n"
                }
                if ($HashTable.Params) {
                    $ExportString += "`t`tParams`t`t= `'$($HashTable.Params)`'`n"
                }
                if ($HashTable.ChocoParams) {
                    $ExportString += "`t`tChocoParams`t= `'$($HashTable.ChocoParams)`'`n"
                }
                if ($HashTable.('OverrideMaintenanceWindow ($True/$False)')) {
                    $ExportString += "`t`tOverrideMaintenanceWindow`t`t= $($HashTable.('OverrideMaintenanceWindow ($True/$False)'))`n"
                }
                if ($HashTable.Ring) {
                    $ExportString += "`t`tRing`t`t= `'$($HashTable.Ring)`'`n"
                }
                if ($HashTable.('VPN ($True/$False)')) {
                    $ExportString += "`t`tVPN`t`t= $($HashTable.('VPN ($True/$False)'))`n"
                }
            }
            $ExportString += "`t}`n"

            $Finished = $host.ui.PromptForChoice($null, 'Finished?', $YesNoOptions, 0)

        } until ($Finished -eq 0) 
        $ExportString += "`n}"
    }
    
    end {
        try {
            if ($NoClobber -and (Test-Path -Path $Path)) {
                Write-Warning "File Already Exists and NoClobber Specified. Requesting Alternative Path"
                $Path = Read-Host -Prompt "Path"
                $ExportString | Set-Content -Path $Path
            }
            else {
                $ExportString | Set-Content -Path $Path
            }
            $FullPath = (Get-Item -Path $Path).Fullname
            Write-Host "File Wriiten to $FullPath"
        }
        catch {
            $_.Exception.Message
        }
    }
}