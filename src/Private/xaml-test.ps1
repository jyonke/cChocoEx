
$xamlfile = "$PSScriptRoot\test-xaml.xml"

<#
    PowerShell XAML Template
    by QuietusPlus
#>

<#
    Include
#>

# .NET Framework classes
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# XAML
[xml]$XAML = Get-Content $xamlfile
$XAML.Window.RemoveAttribute('x:Class')
$XAML.Window.RemoveAttribute('mc:Ignorable')
$XAMLReader = New-Object System.Xml.XmlNodeReader $XAML
$MainWindow = [Windows.Markup.XamlReader]::Load($XAMLReader)

# UI Elements
$XAML.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $MainWindow.FindName($_.Name) }

<#
    Functions
#>



<#
    Initialisation
#>

# Show MainWindow
$MainWindow.ShowDialog()