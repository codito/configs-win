#Requires -Version 2.0
# sublime: word_wrap false

#==============================================================================
# Ensure cleanup at exit. (Based on PowerTab.)
#------------------------------------------------------------------------------
# XXX We should combine this with the TabExpansion cleanup part.
$module = $MyInvocation.MyCommand.ScriptBlock.Module
$module.OnRemove = {
    Unregister-Event -SourceIdentifier 'VirtualEnvWrapper.*'
    Remove-Job -Name 'VirtualenvWrapper.*' -Force
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Restore global Python in registry. Maybe user forgot to run "deactivate".
Switch-DefaultPython

# make sure there is a default value for WORKON_HOME
# you can override this setting in your PoSh profile.
if (-not $env:WORKON_HOME) {
    $env:WORKON_HOME = "$HOME/.virtualenvs"
}

# locate the global python where virtualenvwrapper is installed
if (-not $VIRTUALENVWRAPPER_PYTHON) {
    $global:VIRTUALENVWRAPPER_PYTHON = @(get-command python.exe)[0].definition
}

# TODO: Implement this.
if (-not $VIRTUALENVWRAPPER_VIRTUALENV) {
    $global:VIRTUALENVWRAPPER_VIRTUALENV = 'virtualenv.exe'
}

if (-not $VIRTUALENVWRAPPER_VIRTUALENV_ARGS) {
    $global:VIRTUALENVWRAPPER_VIRTUALENV_ARGS = ''
}

# We'll store global hooks here.
if (-not (test-path variable:VIRTUALENVWRAPPER_HOOK_DIR)) {
    $global:VIRTUALENVWRAPPER_HOOK_DIR = $env:WORKON_HOME
}
elseif (-not (test-path $VIRTUALENVWRAPPER_HOOK_DIR)) {
    write-warning -message "Can't find path '$VIRTUALENVWRAPPER_HOOK_DIR' (`$VIRTUALENVWRAPPER_HOOK_DIR). Defaulting to `$env:WORKON_HOME."
    $global:VIRTUALENVWRAPPER_HOOK_DIR = $env:WORKON_HOME
}

# TODO: Implement this.
if (-not $VIRTUALENVWRAPPER_LOG_DIR) {
    $global:VIRTUALENVWRAPPER_LOG_DIR = $env:WORKON_HOME
}


# Create a new environment, in the WORKON_HOME.
#
# Usage: mkvirtualenv [options] ENVNAME
# (where the options are passed directly to virtualenv)
#
function New-VirtualEnvironment
{
    param($Name)

    try {
        VerifyWorkonHome
        VerifyVirtualEnv
    }
    catch [System.IO.IOException] {
        throw
    }

    [string] $envName = $Name
    push-location $env:WORKON_HOME
        & $global:VIRTUALENVWRAPPER_VIRTUALENV $Name $global:VIRTUALENVWRAPPER_VIRTUALENV_ARGS
    pop-location

    # If they passed a help option or got an error from virtualenv,
    # the environment won't exist.  Use that to tell whether
    # we should switch to the environment and run the hook.
    if ($envName -and (test-path -lit "$ENV:WORKON_HOME/$envName")) {
        [void] (New-Event -SourceIdentifier 'VirtualenvWrapper.PreMakeVirtualEnv' -EventArguments $envName)
        add_posh_to_virtualenv "$ENV:WORKON_HOME/$envName"
        workon $envName
        [void] (New-Event -SourceIdentifier 'VirtualenvWrapper.PostMakeVirtualEnv')
    }
}


function Remove-VirtualEnvironment
{
    if (!$args) {
        throw("You must specify a virtual environment name.")
    }

    $env_name = $args[0]

    try {
       VerifyWorkonHome
    }
    catch [System.IO.IOException] {
        throw($_)
    }

    if (-not (test-path "$env:WORKON_HOME/$env_name")) {
        throw("The specified environment `"$env_name`" does not exist.")
    }

    $env_dir = resolve-path "$env:WORKON_HOME/$env_name" -erroraction silentlycontinue

    if (-not "$env:VIRTUAL_ENV") {
        $curr_env = ""
    }
    else {
        $curr_env = resolve-path "$env:VIRTUAL_ENV" -erroraction silentlycontinue
    }

    if ($env_dir.path -eq $curr_env.path) {
        throw(
            Concat "ERROR: You cannot remove the active environment ('$env_name')." `
                   "Either switch to another environment, or run 'deactivate'."
        )
    }

    [void] (New-Event -SourceIdentifier 'VirtualenvWrapper.PreRemoveVirtualEnv' -EventArguments $env_name)
    remove-item $env_dir -rec
    [void] (New-Event -SourceIdentifier 'VirtualenvWrapper.PostRemoveVirtualEnv'-EventArguments $env_name)
}


# XXX Todo: -Filter, etc.
function Get-VirtualEnvironment
{
    try {
        VerifyWorkonHome
    }
    catch [System.IO.IOException] {
        throw
    }
    # get-childitem "$env:workon_home/*/scripts/activate.ps1" | `
    #             foreach-object { split-path "$((split-path $_ -parent))/.." -leaf }
    GetVirtualEnvData
}

function Set-VirtualEnvironment
<# .DESCRIPTION
    Activates a virtual environment.
#>
{
    $env_name = "$args"
     if (-not([bool]$env_name)) {
        throw("You must specify a virtual environment name.")
    }

    try {
        VerifyWorkonHome
        VerifyWorkonEnvironment $env_name
    }
    catch [System.IO.IOException] {
        throw
    }

    $activate = get-item "$env:WORKON_HOME/$env_name/scripts/activate.ps1" -errora silentlycontinue
    # Deactivate any current environment "destructively" before switching
    # using our override function, if it exists.
    if (get-command "deactivate" -type function -erroraction "silentlycontinue") {
        deactivate
    }

    [void] (New-Event -SourceIdentifier 'VirtualenvWrapper.PreActivateVirtualEnv' -EventArguments $env_name)
    & $activate
    [void] (New-Event -SourceIdentifier 'VirtualenvWrapper.PostActivateVirtualEnv')
}


# Prints the Python version string for the current interpreter.
function virtualenvwrapper_get_python_version
{
    # Uses the Python from the virtualenv because we're trying to
    # determine the version installed there so we can build
    # up the path to the site-packages directory.
    # Escaping needed in Windows.
    python -c 'import sys; print \".\".join(str(p) for p in sys.version_info[:2])'
}


# Prints the path to the site-packages directory for the current environment.
function virtualenvwrapper_get_site_packages_dir
{
    "$env:VIRTUAL_ENV/lib/site-packages"
}


# Does a ``cd`` to the site-packages directory of the currently-active
# virtualenv.
function CDIntoSitePackages
{
    try {
        VerifyWorkonHome
        VerifyActiveEnvironment
    }
    catch [System.IO.IOException] {
        throw($_)
    }
    $site_packages = virtualenvwrapper_get_site_packages_dir
    set-location "$site_packages/$args"
}


# Does a ``cd`` to the root of the currently-active virtualenv.
function CDIntoVirtualEnvironment
{
    try {
        VerifyWorkonHome
        VerifyActiveEnvironment
    }
    catch [System.IO.IOException] {
        throw($_)
    }
    set-location "$env:VIRTUAL_ENV/$args"
}


# Shows the content of the site-packages directory of the currently-active
# virtualenv
function GetSitePackages
{
    try {
        VerifyWorkonHome
        VerifyActiveEnvironment
    }
    catch [System.IO.IOException] {
        throw($_)

    }
    $site_packages = virtualenvwrapper_get_site_packages_dir
    get-childitem $site_packages | format-table name -hidetableheaders

    $path_file = join-path $site_packages "virtualenv_path_extensions.pth"
    if (test-path $path_file) {
        "virtualenv_path_extensions.pth:"
        get-content $path_file
    }
}


# Duplicate the named virtualenv to make a new one.
function Copy-VirtualEnvironment
{
    param([string]$From, [string]$To)

    # Don't bother for the moment. The --relocatable option doesn't work under
    # Windows at the moment...
    # http://virtualenv.openplans.org/#making-environments-relocatable
    throw(new-object "System.NotImplementedException")
}


function workon
{
    if ("$args") {
        Set-VirtualEnvironment "$args"
    }
    else {
        Get-VirtualEnvironment
    }
}


function mktmpenv {
    throw(new-object "System.NotImplementedException")
}


function showvirtualenv {
    throw(new-object "System.NotImplementedException")
}


function add2virtualenv {
    throw(new-object "System.NotImplementedException")
}


function toggleglobasitepackages {
    throw(new-object "System.NotImplementedException")
}


# Import-Module -prefix PREFIX_ breaks aliases.
# =============================================================================
# Public interface
# =============================================================================
new-alias -name "cdsitepackages"    -value "CDIntoSitePackages"
new-alias -name "cdvirtualenv"      -value "CDIntoVirtualEnvironment"
new-alias -name "cpvirtualenv"      -value "Copy-VirtualEnvironment"
new-alias -name "lssitepackages"    -value "GetSitePackages"
new-alias -name "lsvirtualenv"      -value "Get-VirtualEnvironment"
new-alias -name "mkvirtualenv"      -value "New-VirtualEnvironment"
new-alias -name "rmvirtualenv"      -value "Remove-VirtualEnvironment"
# =============================================================================

export-modulemember -function "CDIntoSitePackages"
export-modulemember -function "CDIntoVirtualEnvironment"
export-modulemember -function "Copy-VirtualEnvironment"
export-modulemember -function "GetSitePackages"
export-modulemember -function "New-VirtualEnvironment"
export-modulemember -function "Remove-VirtualEnvironment"
export-modulemember -function "Set-VirtualEnvironment"
export-modulemember -function "Get-VirtualEnvironment"
export-modulemember -function "workon"
export-modulemember -function "mktmpenv"
export-modulemember -function "showvirtualenv"
export-modulemember -function "add2virtualenv"
export-modulemember -function "toggleglobasitepackages"


# Conditionally export additional stuff so that we can test it.
if ($args -and $args[0] -eq "TESTING")
{
    export-modulemember "virtualenvwrapper_get_python_version"
    export-modulemember "virtualenvwrapper_get_site_packages_dir"
}

export-modulemember -alias "cdsitepackages"
export-modulemember -alias "cdvirtualenv"
export-modulemember -alias "cpvirtualenv"
export-modulemember -alias "lssitepackages"
export-modulemember -alias "lsvirtualenv"
export-modulemember -alias "mkvirtualenv"
export-modulemember -alias "rmvirtualenv"


#
# Invoke the initialization hooks
#
Initialize
