function Get-ChocoLogs {
    [CmdletBinding()]
    param (
        # LogType
        [Parameter()]
        [ValidateSet('Summary', 'Full')]
        [string]
        $LogType = 'Summary',
        # Path to Chocolatey Log Folder
        [Parameter()]
        [string]
        $Path = (Join-Path $env:ChocolateyInstall 'logs'),
        # Last Number of Lines
        [Parameter()]
        [int]
        $Last,
        # LogLevel
        [Parameter()]
        [ValidateSet('Information', 'Error', 'Warning')]
        [array]
        $LogLevel,
        # Message Search String
        [Parameter()]
        [regex]
        $SearchString,
        # Minimum Date Filter, defaults to 7 days
        [Parameter()]
        [datetime]
        $MinimumDate = (Get-Date).AddDays(-7),
        # Maximum Date Filter, defaults to now
        [Parameter()]
        [datetime]
        $MaximumDate = (Get-Date)
    )
    
    begin {
        if (-Not(Test-Path $Path)) {
            Write-Warning "Not able to access $Path"
            return
        }
        switch ($LogType) {
            Summary { $Logs = Get-ChildItem -Path $Path -Filter 'choco.summary*.log' | Get-Content }
            Full { $Logs = Get-ChildItem -Path $Path -Filter 'chocolatey*.log' | Get-Content }
            Default {}
        }
        if ($Logs.count -lt 1) {
            Write-Warning "No Log content found in files located at $Path"
            return
        }
        if ($Last -ne $null) {
            #Overprovission and reduce at the end as a hacky speedup
            $Logs = $Logs | Select-Object -Last ($Last * 3)
        }
    }
    
    process {
        $LogsError = [System.Collections.ArrayList]@()
        $LogsWarn = [System.Collections.ArrayList]@()
        $LogsInfo = [System.Collections.ArrayList]@()

        $Logs | ForEach-Object {
            if ($PSItem -Match '\[ERROR\]') {
                $null = $LogsError.Add("$PSItem")
            }
            if ($PSItem -Match '\[WARN \]') {
                $null = $LogsWarn.Add("$PSItem")
            }
            if ($PSItem -Match '\[INFO \]') {
                $null = $LogsInfo.Add("$PSItem")
            }
        }
        $ObjectError = $LogsError | ForEach-Object {
            $String = ((($PSItem -split '\[ERROR\]' | Select-Object -First 1) -split ','))
            $Message = ([string]($PSItem -split '\[ERROR\]' | Select-Object -Last 1)).TrimStart('- ')
            [datetime]$Date = ($String[0]) + ('.') + ($String[1] -split ' ' | Select-Object -First 1)
            [PSCustomObject]@{
                Date     = $Date
                LogLevel = 'Error'
                Message  = $Message
            }
        }
        $ObjectWarn = $LogsWarn | ForEach-Object {
            $String = ((($PSItem -split '\[WARN \]' | Select-Object -First 1) -split ','))
            $Message = ([string]($PSItem -split '\[WARN \]' | Select-Object -Last 1)).TrimStart('- ')
            [datetime]$Date = ($String[0]) + ('.') + ($String[1] -split ' ' | Select-Object -First 1)
            [PSCustomObject]@{
                Date     = $Date
                LogLevel = 'Warning'
                Message  = $Message
            }
        }
        $ObjectInfo = $LogsInfo | ForEach-Object {
            $String = ((($PSItem -split '\[INFO \]' | Select-Object -First 1) -split ','))
            $Message = ([string]($PSItem -split '\[INFO \]' | Select-Object -Last 1)).TrimStart('- ')
            
            [datetime]$Date = ($String[0]) + ('.') + ($String[1] -split ' ' | Select-Object -First 1)
            [PSCustomObject]@{
                Date     = $Date
                LogLevel = 'Information'
                Message  = $Message
            }
        }
        $ObjectReturn = $ObjectError + $ObjectWarn + $ObjectInfo | Sort-Object -Property Date | Where-Object { ($_.Date -ge $MinimumDate) -and ($_.Date -le $MaximumDate) }
        if ($LogLevel) {
            $ObjectReturn = $ObjectReturn | Where-Object { $LogLevel -contains $_.LogLevel }
        }
        if ($SearchString) {
            $ObjectReturn = $ObjectReturn | Where-Object { $_.Message -match $SearchString }
        }
        if ($Last) {
            $ObjectReturn = $ObjectReturn | Select-Object -Last $Last
        }
    }
    
    end {
        return $ObjectReturn
    }
}