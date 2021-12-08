<#
.SYNOPSIS
    Creates a PowerShell Job that runs as SYSTEM to automatically runs cChocoEx bootstrap continuously
.DESCRIPTION
    If no boostrap.ps1 script is present at "$env:ProgramData\cChocoEx\bootstrap.ps1" a miniminal one will be copied to use. 
.EXAMPLE
    PS C:\> Register-cChocoExBootStrapJob -LoopDelay 180
    Creates a Powershell job that will execute "$env:ProgramData\cChocoEx\bootstrap.ps1" every 180 minutes and at startup.
.INPUTS
    None
.OUTPUTS
    None
#>
function Register-cChocoExBootStrapJob {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]
        $LoopDelay
    )
    
    begin {
        #Gather Variables
        Set-GlobalVariables
        $Name = 'cChocoExBootstrapJob'
        $FilePath = "$env:ProgramData\cChocoEx\bootstrap.ps1"
        $ScheduledJobOption = New-ScheduledJobOption -RunElevated -ContinueIfGoingOnBattery -StartIfOnBattery -MultipleInstancePolicy 'StopExisting' -RequireNetwork
        $JobTrigger01 = New-JobTrigger -AtStartup
        $JobTrigger02 = New-JobTrigger -Once -At ((Get-Date).AddMinutes($LoopDelay)) -RepeatIndefinitely -RepetitionInterval (New-TimeSpan -Minutes $LoopDelay)

        #ScheduledJobSplat
        $ScheduledJobParams = @{
            FilePath           = $FilePath
            Name               = $Name
            ScheduledJobOption = $ScheduledJobOption 
            Trigger            = @($JobTrigger01, $JobTrigger02)
        }
    }
    
    process {
        #Check For Existig Job
        $CurrentJob = Get-ScheduledJob -Name $Name -ErrorAction SilentlyContinue

        #Check for existing bootstrap.ps1
        Write-Log -Severity 'Information' -Message "Checking for File - $FilePath"
        if (-Not(Test-Path -Path $FilePath)) {
            #Copy Minimal Bootstrap
            Write-Log -Severity 'Information' -Message "$FilePath Not Found - Copying minimal boostrap.ps1"
            try {
                $null = Copy-Item -Path (Join-Path -Path ($PSScriptRoot | Split-Path) -ChildPath 'scripts\bootstrap.min.ps1') -Destination $FilePath -Force
                Write-Log -Severity 'Information' -Message "Success"
            }
            catch {
                Write-Log -Severity 'Error' -Message "Failure"
                Write-Log -Severity 'Error' -Message "$($_.Exception.Message)"
            }
        }
        else {
            Write-Log -Severity 'Information' -Message "$FilePath Already Exists"
        }

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