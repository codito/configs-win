## Portable Profile
## Created: Sat 15 Jan 2011 02:15:57 PM India Standard Time
## Last Modified: 11/05/2018, 16:27:40 India Standard Time

$env:PortableEnv = "f:\apps"
$env:TERM = 'cygwin'
$env:LESS = 'FRSX'

# Languages
$env:WORKON_HOME = "~\.virtualenvs"

# GIT
#$env:PLINK_PROTOCOL = "ssh"
#$env:GIT_INSTALL_ROOT = "$env:PortableEnv\git"
#$env:PATH += ";$env:GIT_INSTALL_ROOT\cmd"

# Modules
Import-Module TabExpansion++
if ($host.Name -eq 'ConsoleHost')
{
    Import-Module PSReadline
}
#Import-Module powertab # must be imported first (hg/git depend on this!)
Import-Module "git-status-cache-posh-client\GitStatusCachePoshClient.psm1"
Import-Module posh-git

## Prompt
function prompt
{
    $date = $(date)
    $dateString = $date.Hour.ToString()+":"+$date.Minute.ToString()+":"+$date.Second.ToString()
    #Write-Host $dateString" ["$(get-location)"]" -foregroundcolor green
    Write-Host $dateString" ["$(get-location)"]" -foregroundcolor green -nonewline
    Write-Host $(Write-VcsStatus)
    Write-Host $((get-history -count 1).Id+1)"$" -nonewline
    return " "
}

$global:GitPromptSettings.EnableWindowTitle = $false

## Readline
Set-PSReadlineOption -EditMode Emacs

## Aliases
Enable-GitShortcuts
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
$env:EDITOR = "gvim.exe"

# Script Directory
$env:PATH += ";"+$env:SCRIPTDIR+";."

## User applications
# Get my global helper functions
. $(Join-Path $(Split-Path $MyInvocation.MyCommand.Path) "functions.ps1")

# ACK
function ack
{
    $perlPath = $((Get-ChildItem $(where.exe git.exe)).Directory).FullName + "\..\bin\perl.exe"
    & $perlPath $((resolve-path "~\bin\standalone-ack").path) $args
}
