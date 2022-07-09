$PublicFunctions = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$PrivateFunctions = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )

foreach ($Import in @($PublicFunctions + $PrivateFunctions)) {
    $Import
    Try { . $Import.FullName -Verbose }
    Catch { Write-Error -Message "Failed to import function $($Import.FullName): $_" }
}

Export-ModuleMember -Function $PublicFunctions.BaseName

#Ensure cChocoEx Data Folder Structure is Created
Set-cChocoExFolders

#Ensure Registry Is Setup
Set-RegistryConfiguration

#Ensure EventLog Sources are Setup
Register-EventSource