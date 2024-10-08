## Portable Profile
## Created: Sat 15 Jan 2011 02:15:57 PM India Standard Time
## Last Modified: 21/12/2021, 08:04:52 +0530

$env:TERM="xterm-256color"
$env:XDG_CONFIG_HOME=Resolve-Path("~/.config").ToString()
$env:XDG_DATA_HOME=Resolve-Path("~/.local/share").ToString()

## Prompt
$env:STARSHIP_LOG="error"
if (Get-Command -Name starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

## Readline
Set-PSReadlineOption -EditMode Emacs

## Aliases
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
$env:FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'

# Script Directory
$env:PATH += ";"+$env:SCRIPTDIR+";."
$env:PYTHONHOME = Resolve-Path("~\scoop\apps\python\current")

## User applications
# Scoop search
if (Get-Command -Name scoop-search -ErrorAction SilentlyContinue) {
    Invoke-Expression (&scoop-search --hook)
}

# Get my global helper functions
function global:loadp { . $Profile.CurrentUserAllHosts }
function global:editp { & $env:EDITOR $Profile.CurrentUserAllHosts }
function global:loada { . $($(Join-Path $(Split-Path $Profile.CurrentUserAllHosts) "functions.ps1")) }
function global:edita { & $env:EDITOR $(Join-Path $(Split-Path $Profile.CurrentUserAllHosts) "functions.ps1") }

loada
