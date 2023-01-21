function ConvertTo-PowerShellDataFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [object[]]$InputObject
    )

    begin {
        try {
            Install-PSScriptAnalyzer
        }
        catch {
            Write-Error $_.Exception.Message
            continue
        }
    }
    process {
        $output = "@{`n"
        foreach ($key in $InputObject.Keys) {
            $value = $InputObject[$key]
    
            $output += "  `"$key`" = @{`n"
            foreach ($k in $value.Keys) {
                $output += "    `"$k`" = `"$($value[$k])`"`n"
            }
            $output += "  }`n"
        }
        $output += "}`n"
    
        $output | Invoke-Formatter
    }
    end {

    }

}
