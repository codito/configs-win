<#
.Synopsis 
    Setups current shell to use python 3 instead of the default python install
.Description 
    Modifies PYTHONHOME variable to use Python 3 installation
.Inputs
    None
.Outputs
    None
.Example 
    py3init
.Notes 
    Name:          py3init
    Author:        Arun Mahapatra
    Last Modified: 
    #Requires -version 2
#>

$Python27InstallDir = Join-Path $env:SystemDrive "Python27"
$Python3InstallDir = Join-Path $env:SystemDrive "Python33"

if (!(Test-Path $Python3InstallDir))
{
    Write-Error "Python 3 installation not found at $Python3InstallDir"
}

$env:PYTHONHOME = $Python3InstallDir
$env:Path = $env:Path.replace($Python27InstallDir, $Python3InstallDir)

if ($LastExitCode -eq 0)
{
    Write-Host "You're in a Python 3 shell :)"
}
