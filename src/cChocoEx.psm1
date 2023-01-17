$PublicFunctions = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$PrivateFunctions = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Formats = @( Get-ChildItem -Path $PSScriptRoot\Formats\*.ps1xml -Recurse -ErrorAction SilentlyContinue )

foreach ($Import in @($PublicFunctions + $PrivateFunctions)) {
    $Import
    Try { 
        . $Import.FullName
    }
    Catch {
        Write-Error -Message "Failed to import function $($Import.FullName): $_" 
    }
}

foreach ($Format in $Formats) {
    $Format
    try {
        Update-FormatData -PrependPath $Format.FullName
    }
    catch {
        Write-Error -Message "Failed to import format $($Format.FullName): $_" 
    }
}

Export-ModuleMember -Function $PublicFunctions.BaseName
Export-ModuleMember -Function $Public.BaseName
Set-cChocoExEnvironment
