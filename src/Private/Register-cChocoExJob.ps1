function Register-cChocoExJob {
    [CmdletBinding()]
    param ()
    
    begin {
        #Gather Variables
        $Name = 'cChocoExJob01'
        $ScheduledJobOption = New-ScheduledJobOption -RunElevated -ContinueIfGoingOnBattery -StartIfOnBattery -MultipleInstancePolicy 'StopExisting '
        $JobTrigger01 = New-JobTrigger -AtLogOn
        $JobTrigger02 = New-JobTrigger -AtStartup
        $ScriptBlock = {
            $Path = "HKLM:\Software\cChocoEx\"
    
            do {
                $ItemProperty = Get-ItemProperty -Path $Path -Name 'OverRideMaintenanceWindow' -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 5
            } until ($ItemProperty.OverRideMaintenanceWindow -eq 1)

            Start-cChocoEx -OverrideMaintenanceWindow -EnableNotifications
        }

        #ScheduledJobSplat
        $ScheduledJobParams = @{
            ScriptBlock        = $ScriptBlock
            Name               = $Name
            ScheduledJobOption = $ScheduledJobOption 
            Trigger            = @($JobTrigger01, $JobTrigger02)
        }
    }
    
    process {
        #Check For Existig Job
        $CurrentJob = Get-ScheduledJob -Name $Name -ErrorAction SilentlyContinue

        #Unregister Existing Job If Found
        if ($CurrentJob) {
            Write-Log -Severity 'Information' -Message "Existing Scheduled Job $Name Found"
            Write-Log -Severity 'Information' -Message "Unregistering Scheduled Job $Name"
            try {
                $CurrentJob | Unregister-ScheduledJob -Force
                Write-Log -Severity 'Information' -Message "Unregistering Scheduled Job $Name - Success"
            }
            catch {
                Write-Log -Severity 'Error' -Message "Unregistering Scheduled Job $Name - Failure"
                Write-Log -Severity 'Error' -Message "$($_.Exception.Message)"
            }
            
        }

        #Register Job
        Write-Log -Severity 'Information' -Message "Registering Scheduled Job $Name"
        try {
            $UserID = "NT AUTHORITY\SYSTEM"
            $TaskPath = "\Microsoft\Windows\PowerShell\ScheduledJobs"

            $null = Register-ScheduledJob @ScheduledJobParams
            $ScheduledTaskPrincipal = New-ScheduledTaskPrincipal -UserID $UserID -LogonType ServiceAccount -RunLevel Highest
            $null = Set-ScheduledTask -TaskPath $TaskPath -TaskName $Name -Principal $ScheduledTaskPrincipal
            Write-Log -Severity 'Information' -Message "Registering Scheduled Job $Name - Success"
        }
        catch {
            Write-Log -Severity 'Error' -Message "Registering Scheduled Job $Name - Failure"
            Write-Log -Severity 'Error' -Message "$($_.Exception.Message)"
        }
    }
    
    end {
        #Validate Job Exists
        try {
            $null = Get-ScheduledJob -Name $Name
        }
        catch {
            Write-Log -Severity 'Error' -Message "Required Scheduled Job $Name Not Found"
            Write-Log -Severity 'Error' -Message "$($_.Exception.Message)"
        }
    }
}