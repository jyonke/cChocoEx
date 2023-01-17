<#
.SYNOPSIS
Returns Chocolatey Sources DSC Configuration in cChocoEx
.DESCRIPTION
Returns Chocolatey Sources DSC Configuration in cChocoEx as a PowerShell Custom Object
#>
function Get-cChocoExSource {
    [CmdletBinding(DefaultParameterSetName = 'Present')]
    param (
        # Path
        [Alias('FullName', 'Path')]
        [Parameter(ValueFromPipelineByPropertyName = $true, Position = 0)]
        [string[]]
        $cChocoExSourceFile = (Join-Path -Path $Global:cChocoExConfigurationFolder -ChildPath 'sources.psd1'),
        # Name
        [Parameter()]
        [string]
        $Name,
        # Ensure
        [Parameter(ParameterSetName = 'Present')]
        [Parameter(ParameterSetName = 'Absent')]
        [ValidateSet('Present', 'Absent')]
        [string]
        $Ensure,
        # Source
        [Parameter(ParameterSetName = 'Present')]
        [string]
        $Source,
        # Priority
        [Parameter(ParameterSetName = 'Present')]
        [System.Nullable[int]]
        $Priority,
        # User
        [Parameter(ParameterSetName = 'Present')]
        [string]
        $User,
        # Password
        [Parameter(ParameterSetName = 'Present')]
        [string]
        $Password,
        # Keyfile
        [Parameter(ParameterSetName = 'Present')]
        [string]
        $Keyfile,
        # VPN
        [Parameter(ParameterSetName = 'Present')]
        [Nullable[boolean]]
        $VPN = $null     
    )
    
    begin {
        [array]$array = @()
    }
    
    process {
        if (Test-Path $cChocoExSourceFile) {
            $ConfigImport = Import-PowerShellDataFile -Path $cChocoExSourceFile -ErrorAction Continue
            $Configurations = $ConfigImport | ForEach-Object { $_.Values }
            $FullName = Get-Item $cChocoExSourceFile | Select-Object -ExpandProperty FullName
            Write-Verbose "Processing:$FullName"
                    
            #Validate Keys
            $ValidHashTable = @{
                Name     = $null
                Ensure   = $null
                Priority = $null
                Source   = $null
                User     = $null
                Password = $null
                KeyFile  = $null
                VPN      = $null
            }
            
            $Configurations.Keys | Sort-Object -Unique | ForEach-Object {
                if ($_ -notin $ValidHashTable.Keys) {
                    Write-Error "Invalid Configuration Key ($_) Found In File: $cChocoExSourceFile"
                    Return
                }
            }

            $Configurations | ForEach-Object {
                $array += [PSCustomObject]@{
                    PSTypeName = 'cChocoExSource'
                    Name       = $_.Name
                    Ensure     = $_.Ensure
                    Priority   = $_.Priority
                    Source     = $_.Source
                    User       = $_.User
                    Password   = $_.Password
                    KeyFile    = $_.KeyFile
                    VPN        = $_.VPN
                    Path       = $FullName
                }
            }
        }
        else {
            Write-Warning 'No cChocoEx Sources file found'
        }
    }
    
    end {
        #Filter objects
        if ($Name) {
            $array = $array | Where-Object { $_.Name -eq $Name }
        }
        if ($Ensure) {
            $array = $array | Where-Object { $_.Ensure -eq $Ensure }
        }
        if ($Priority -ne $null) {
            $array = $array | Where-Object { [int]$_.Priority -eq [int]$Priority }
        }
        if ($Source) {
            $array = $array | Where-Object { $_.Source -eq $Source }
        }
        if ($User) {
            $array = $array | Where-Object { $_.User -eq $User }
        }
        if ($Password) {
            $array = $array | Where-Object { $_.Password -eq $Password }
        }
        if ($Keyfile) {
            $array = $array | Where-Object { $_.Keyfile -eq $Keyfile }
        }
        if ($VPN -ne $Null) {
            $array = $array | Where-Object { [string]$_.VPN -eq [string]$VPN }
        }
        return $array
    }
}