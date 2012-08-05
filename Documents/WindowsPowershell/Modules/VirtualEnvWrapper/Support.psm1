# set-strictmode -version "2.0"
$script:thisDir = split-path $MyInvocation.MyCommand.Path -parent


function Concat
{
    "$args"
}


# verify that the WORKON_HOME directory exists
function VerifyWorkonHome
{
    if (-not ((test-path env:WORKON_HOME) -and (test-path $env:WORKON_HOME)))
    {
        throw (new-object `
                    -typename "system.io.directorynotfoundexception" `
                    -argumentlist (Concat `
                                    "Virtualenvwrapper: Virtual environments directory" `
                                    "'$env:WORKON_HOME' does not exist. Create it or set" `
                                    "`$env:WORKON_HOME to an existing directory.")
                                    )
    }
}


# XXX: Test this
# set up virtualenvwrapper properly
function Initialize
{
    VerifyWorkonHome

    $pathToExtensions = join-path $script:thisDir 'Extensions'
    get-childitem $pathToExtensions -Filter 'Extension.*.ps1' | foreach-object { & $_.fullname }

    [void] (New-Event -SourceIdentifier 'VirtualEnvWrapper.Initialize')
}


function global:VerifyVirtualEnv
{
    if (!$VIRTUALENVWRAPPER_VIRTUALENV) {
        throw "`$VIRTUALENVWRAPPER_VIRTUALENV is not defined."
    }

    $venv = get-command $global:VIRTUALENVWRAPPER_VIRTUALENV -erroraction silentlycontinue
    if (-not $venv) {
        throw(new-object `
                -typename "System.IO.FileNotFoundException" `
                -argumentlist "ERROR: virtualenvwrapper could not find virtualenv in your PATH.")
    }
}


# verify that the requested environment exists
function global:VerifyWorkonEnvironment
{
    if (-not (test-path "$env:WORKON_HOME/$($args[0])"))
    {
        throw(new-object `
                        -typename "system.io.directorynotfoundexception" `
                        -argumentlist (Concat `
                                        "ERROR: Environment '$($args[0])' does" `
                                        "not exist. Create it with 'mkvirtualenv" `
                                        "$($args[0])'.")
                                        )
    }
}


# verify that the active environment exists
function global:VerifyActiveEnvironment
{
    if (-not ((test-path env:VIRTUAL_ENV) -and (test-path $env:VIRTUAL_ENV)))
    {
        throw(new-object `
                    -typename "system.io.ioexception" `
                    -argumentlist (Concat `
                                    "ERROR: no virtualenv active, or" `
                                    "active virtualenv is missing")
                                    )
    }
}

###############################################################################
# Formatting helpers
#------------------------------------------------------------------------------
filter LooksLikeAVirtualEnv
{
    param([IO.DirectoryInfo]$path)

    $_ | where-object { $_.PSIsContainer -and `
                        (test-path (join-path $_.FullName "Scripts/activate.ps1"))
                        }
}


function NewVirtualEnvData
{
    param([IO.DirectoryInfo]$path)

    $info = new-object 'PSObject' -property @{'PathInfo'=$path}
    add-member -inputobject $info `
                    -membertype 'ScriptProperty' `
                    -name 'Name' -value { $this.PathInfo.Name }
    add-member -inputobject $info `
                    -membertype 'NoteProperty' `
                    -name 'PathToScripts' -value (join-path $path.Fullname 'Scripts')
    add-member -inputobject $info `
                    -membertype 'NoteProperty' `
                    -name 'PathToSitePackages' -value (join-path $path.Fullname 'Lib/site-packages')
    # XXX: Find out whether PSCustomObject can be formatted with .ps1xml files.
    # http://blogs.msdn.com/b/powershell/archive/2006/04/30/how-powershell-formatting-and-outputting-really-works.aspx
    # add-member -inputobject $info -membertype 'ScriptProperty' -name 'Hooks' -value { get-childitem $this.PathToScripts -filter '*.ps1' }

    $info
}


function GetVirtualEnvData
{
    get-childitem $env:WORKON_HOME | LooksLikeAVirtualEnv | ForEach-Object { NewVirtualEnvData $_ }
}
###############################################################################
