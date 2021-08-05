# Visual Studio powershell helper script
# Based on https://intellitect.com/enter-vsdevshell-powershell/

function VsVars32($version)
{
    $installPath = &"${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -version "$version" -prerelease -property installationpath
    Import-Module (Join-Path $installPath "Common7\Tools\Microsoft.VisualStudio.DevShell.dll")
    Enter-VsDevShell -VsInstallPath $installPath -SkipAutomaticLocation
    [System.Console]::Title = "Visual Studio " + $version + " Windows Powershell"
}

VsVars32("17.0")
# vim: set ft=powershell:
