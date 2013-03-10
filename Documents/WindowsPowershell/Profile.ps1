## Portable Profile
## Created: Sat 15 Jan 2011 02:15:57 PM India Standard Time
## Last Modified: 

$env:PortableEnv = "g:\apps"
$env:TERM = 'cygwin'
$env:LESS = 'FRSX'

# Languages
$env:PATH = "C:\Python27\Scripts;" + $env:PATH
$env:WORKON_HOME = "~\.virtualenvs"

# GIT
#$env:PLINK_PROTOCOL = "ssh"
#$env:GIT_INSTALL_ROOT = "$env:PortableEnv\git"
#$env:PATH += ";$env:GIT_INSTALL_ROOT\cmd"

# Modules
Import-Module powertab # must be imported first (hg/git depend on this!)
Import-Module posh-git
Import-Module posh-hg

## Prompt
function prompt
{
    $date = $(date)
    $dateString = $date.Hour.ToString()+":"+$date.Minute.ToString()+":"+$date.Second.ToString()
    Write-Host $dateString" ["$(get-location)"]" -foregroundcolor green
    #Write-Host $dateString" ["$(get-location)"]" -foregroundcolor green -nonewline
    #Write-Host $(Write-VcsStatus)
    Write-Host $((get-history -count 1).Id+1)"$" -nonewline
    return " "
}

## Aliases
#set-alias la ls -recurse
rm -force alias:cd

set-alias cal gadget-calendar
set-alias cd pushd;set-location
set-alias cd- popd
set-alias grep select-string
set-alias l get-childitem
set-alias whereis where.exe
set-alias wc measure-object

## Globals
# Environment variables
$env:Path = "$env:PortableEnv\Path;$env:PortableEnv\GnuWin32\bin;" + $env:Path
$env:SCRIPTDIR = Resolve-Path("~\bin").ToString()
$env:EDITOR = "gvim.bat"

# Script Directory
$env:PATH += ";"+$env:SCRIPTDIR+";."

## User applications
# Get my global helper functions
. $(Join-Path $(Split-Path $MyInvocation.MyCommand.Path) "functions.ps1")

# ACK
function ack
{
    & $env:PortableEnv\git\bin\perl.exe $((resolve-path "~\bin\standalone-ack").path) $args
}
