function Get-ChocoLogs {
    [CmdletBinding(DefaultParameterSetName = 'Filter')]
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
        [Parameter(ParameterSetName = "Filter")]
        [int]
        $Last = 3000,
        # LogLevel
        [Parameter()]
        [ValidateSet('Information', 'Error', 'Warning', 'Debug')]
        [array]
        $LogLevel,
        # Message Search String
        [Parameter()]
        [Alias('Match')]
        [regex]
        $SearchString,
        # Minimum Date Filter, defaults to 7 days
        [Parameter(ParameterSetName = "Filter")]
        [datetime]
        $MinimumDate = (Get-Date).AddDays(-30),
        # Maximum Date Filter, defaults to now
        [Parameter(ParameterSetName = "Filter")]
        [datetime]
        $MaximumDate = (Get-Date),
        # Return All
        [Parameter(ParameterSetName = "All")]
        [switch]
        $All
    )
    
    if ($All) {
        $MinimumDate = [datetime]"01/01/1900"
        $Last = $null
    }
    if (-Not(Test-Path $Path)) {
        Write-Warning "Not able to access $Path"
        return
    }
    switch ($LogType) {
        Summary { $Logs = Get-ChildItem -Path $Path -Filter 'choco.summary*.log' | Where-Object { $_.LastWriteTime -ge $MinimumDate } | Get-Content }
        Full { $Logs = Get-ChildItem -Path $Path -Filter 'chocolatey*.log' | Where-Object { $_.LastWriteTime -ge $MinimumDate } | Get-Content }
        Default {}
    }
    if ($Logs.count -lt 1) {
        Write-Warning "No Log content found in files located at $Path"
        return
    }
    if ($Last -gt 0) {
        #Overprovission and reduce at the end as a hacky speedup
        $Logs = $Logs | Select-Object -Last ($Last * 3)
    }

    #Fix misc line returns
    $i = 0
    $Logsf = $Logs | ForEach-Object {
        if ($PSItem -match '\[ERROR\]|\[WARN \]|\[INFO \]|\[DEBUG\]') {
            if (($PSItem -split '] - ' | Select-Object -Last 1) -eq "") {
                $PSItem + $Logs[$i + 1]
            }
            if (($PSItem -split '] - ' | Select-Object -Last 1) -ne "") {
                $PSItem
            }
        }    
        $i++
    }

    $LogsError = [System.Collections.ArrayList]@()
    $LogsWarn = [System.Collections.ArrayList]@()
    $LogsInfo = [System.Collections.ArrayList]@()
    $LogsDebug = [System.Collections.ArrayList]@()

    $Logsf | ForEach-Object {
        if ($_ -match $SearchString -or $null -eq $SearchString) {
            if ($PSItem -Match '\[ERROR\]') {
                $null = $LogsError.Add("$PSItem")
            }
            if ($PSItem -Match '\[WARN \]') {
                $null = $LogsWarn.Add("$PSItem")
            }
            if ($PSItem -Match '\[INFO \]') {
                $null = $LogsInfo.Add("$PSItem")
            }
            if ($PSItem -Match '\[DEBUG\]') {
                $null = $LogsDebug.Add("$PSItem")
            }        
        }
        
    }

    #if ($SearchString -ne $null) {
    #    Write-Verbose "RegEx SearchString: $SearchString"
    #    $Logsf = $Logsf | Where-Object { $_ -match $SearchString }
    #}

    if ($LogLevel -contains 'Error' -or $null -eq $LogLevel) {
        $Job0 = Start-Job -ScriptBlock {
            $using:LogsError | ForEach-Object {
                $String = ((($PSItem -split '\[ERROR\]' | Select-Object -First 1) -split ','))
                $Message = ([string]($PSItem -split '\[ERROR\]' | Select-Object -Last 1)).TrimStart('- ')
                [datetime]$Date = ($String[0]) + ('.') + ($String[1] -split ' ' | Select-Object -First 1)
                [PSCustomObject]@{
                    Date     = $Date
                    LogLevel = 'Error'
                    Message  = $Message
                }
            }
        }
    }
    if ($LogLevel -contains 'Warning' -or $null -eq $LogLevel) {
        $Job1 = Start-Job -ScriptBlock {
            $using:LogsWarn | ForEach-Object {
                $String = ((($PSItem -split '\[WARN \]' | Select-Object -First 1) -split ','))
                $Message = ([string]($PSItem -split '\[WARN \]' | Select-Object -Last 1)).TrimStart('- ')
                [datetime]$Date = ($String[0]) + ('.') + ($String[1] -split ' ' | Select-Object -First 1)
                [PSCustomObject]@{
                    Date     = $Date
                    LogLevel = 'Warning'
                    Message  = $Message
                }
            }
        }
    }
    if ($LogLevel -contains 'Information' -or $null -eq $LogLevel) {
        $Job2 = Start-Job -ScriptBlock {
            $using:LogsInfo | ForEach-Object {
                $String = ((($PSItem -split '\[INFO \]' | Select-Object -First 1) -split ','))
                $Message = ([string]($PSItem -split '\[INFO \]' | Select-Object -Last 1)).TrimStart('- ')
                
                [datetime]$Date = ($String[0]) + ('.') + ($String[1] -split ' ' | Select-Object -First 1)
                [PSCustomObject]@{
                    Date     = $Date
                    LogLevel = 'Information'
                    Message  = $Message
                }
            }
        }  
    }
    if ($LogLevel -contains 'Debug' -or $null -eq $LogLevel) {
        $Job3 = Start-Job -ScriptBlock {
            $using:LogsDebug | ForEach-Object {
                $String = ((($PSItem -split '\[DEBUG\]' | Select-Object -First 1) -split ','))
                $Message = ([string]($PSItem -split '\[DEBUG\]' | Select-Object -Last 1)).TrimStart('- ')
                
                [datetime]$Date = ($String[0]) + ('.') + ($String[1] -split ' ' | Select-Object -First 1)
                [PSCustomObject]@{
                    Date     = $Date
                    LogLevel = 'Debug'
                    Message  = $Message
                }
            }
        }
    }

    $Job0 | Wait-Job -ErrorAction SilentlyContinue | Out-Null
    $Job1 | Wait-Job -ErrorAction SilentlyContinue | Out-Null
    $Job2 | Wait-Job -ErrorAction SilentlyContinue | Out-Null
    $Job3 | Wait-Job -ErrorAction SilentlyContinue | Out-Null

    $ObjectError = $job0 | Receive-Job -ErrorAction SilentlyContinue | Select-Object -Property Date, LogLevel, Message
    $ObjectWarn = $job1 | Receive-Job -ErrorAction SilentlyContinue | Select-Object -Property Date, LogLevel, Message
    $ObjectInfo = $job2 | Receive-Job -ErrorAction SilentlyContinue | Select-Object -Property Date, LogLevel, Message
    $ObjectDebug = $job3 | Receive-Job -ErrorAction SilentlyContinue | Select-Object -Property Date, LogLevel, Message
    
    [array]$ObjectReturn = @()
    if ($ObjectError.Count -gt 0) {
        $ObjectReturn += $ObjectError 
    }
    if ($ObjectWarn.Count -gt 0) {
        $ObjectReturn += $ObjectWarn 
    }
    if ($ObjectInfo.Count -gt 0) {
        $ObjectReturn += $ObjectInfo 
    }
    if ($ObjectDebug.Count -gt 0) {
        $ObjectReturn += $ObjectDebug 
    }

    $ObjectReturn = $ObjectReturn | Sort-Object -Property Date | Where-Object { ($_.Date -ge $MinimumDate) -and ($_.Date -le $MaximumDate) }
    if ($LogLevel -ne $null) {
        Write-Verbose "Filtering LogLevel: $LogLevel"
        $ObjectReturn = $ObjectReturn | Where-Object { $LogLevel -contains $_.LogLevel }
    }
    if ($Last -gt 0) {
        Write-Verbose "Return Last: $Last"
        $ObjectReturn = $ObjectReturn | Select-Object -Last $Last
    }
    return $ObjectReturn
}