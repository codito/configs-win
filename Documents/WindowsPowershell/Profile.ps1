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
$env:PLINK_PROTOCOL = "ssh"
$env:GIT_INSTALL_ROOT = "$env:PortableEnv\git"
$env:PATH += ";$env:GIT_INSTALL_ROOT\cmd"

## prompt
function prompt
{
    $date = $(date)
    $dateString = $date.Hour.ToString()+":"+$date.Minute.ToString()+":"+$date.Second.ToString()
    Write-Host $dateString" ["$(get-location)"]" -foregroundcolor green
    Write-Host $((get-history -count 1).Id+1)"$" -nonewline
    return " "
}

## Aliases
#set-alias la ls -recurse
rm -force alias:where
rm -force alias:cd

set-alias cal gadget-calendar
set-alias cd pushd;set-location
set-alias cd- popd
set-alias grep select-string
set-alias l get-childitem
set-alias whereis where
set-alias wc measure-object

## Globals
# Environment variables
$env:Path = "$env:PortableEnv\Path;$env:PortableEnv\GnuWin32\bin;" + $env:Path
$env:SCRIPTDIR = Resolve-Path("$env:PortableEnv\bin").ToString()
$env:EDITOR = "gvim"

# Script Directory
$env:PATH += ";"+$env:SCRIPTDIR+";."

## User applications
# ACK
function ack
{
    & $env:PortableApps\git\bin\perl.exe "$env:PortableEnv\bin\standalone-ack" $args
}
