## Portable Profile
## Created: Sat 15 Jan 2011 02:15:57 PM India Standard Time
## Last Modified: 23/07/2021, 08:47:43 India Standard Time

$env:TERM = 'cygwin'
$env:LESS = 'FRSX'

# Languages
$env:WORKON_HOME = "~\.virtualenvs"

# GIT
#$env:PLINK_PROTOCOL = "ssh"
#$env:PATH += ";$env:GIT_INSTALL_ROOT\cmd"

# Modules
if ($host.Name -eq 'ConsoleHost')
{
    Import-Module PSReadline
}
#Import-Module powertab # must be imported first (hg/git depend on this!)
#Import-Module posh-git

## Prompt
if ($(where.exe starship) -ne $null) {
    Invoke-Expression (&starship init powershell)
}

#function prompt
#{
    #$date = $(date)
    #$dateString = $date.Hour.ToString()+":"+$date.Minute.ToString()+":"+$date.Second.ToString()
    ##Write-Host $dateString" ["$(get-location)"]" -foregroundcolor green
    #Write-Host $dateString" ["$(get-location)"]" -foregroundcolor green -nonewline
    #Write-Host $(Write-VcsStatus)
    #Write-Host $((get-history -count 1).Id+1)"$" -nonewline
    #return " "
#}

#$global:GitPromptSettings.EnableWindowTitle = $false

## Readline
Set-PSReadlineOption -EditMode Emacs

## Aliases
#Enable-GitShortcuts
#set-alias la ls -recurse
rm -force alias:cd
set-alias cd j
set-alias cd- popd

set-alias cal gadget-calendar
set-alias grep select-string
set-alias l get-childitem
set-alias whereis where.exe
set-alias wc measure-object

## Globals
# Environment variables
$env:SCRIPTDIR = Resolve-Path("~\bin").ToString()
$env:EDITOR = "gvim.exe"

# Script Directory
$env:PATH += ";"+$env:SCRIPTDIR+";."
$env:PYTHONHOME = Resolve-Path("~\scoop\apps\python\current")

## User applications
# Get my global helper functions
function global:loadp { . $Profile.CurrentUserAllHosts }
function global:editp { & $env:EDITOR $Profile.CurrentUserAllHosts }
function global:loada { . $($(Join-Path $(Split-Path $Profile.CurrentUserAllHosts) "functions.ps1")) }
function global:edita { & $env:EDITOR $(Join-Path $(Split-Path $Profile.CurrentUserAllHosts) "functions.ps1") }

loada
