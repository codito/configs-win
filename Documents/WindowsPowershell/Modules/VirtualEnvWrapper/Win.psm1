# set-strictmode -version "2.0"

$ACTIVATE_SCRIPT_TEMPLATE = @'
# This file must be dot sourced from PoSh; you cannot run it
# directly. Do this: . ./activate.ps1

# FIXME: clean up unused vars.
$script:THIS_PATH = $myinvocation.mycommand.path
$script:BASE_DIR = split-path (resolve-path "$THIS_PATH/..") -Parent
$script:DIR_NAME = split-path $BASE_DIR -Leaf

# unset irrelevant variables
if (test-path function:deactivate) {
    deactivate -nondestructive
}

$VIRTUAL_ENV = $BASE_DIR
$env:VIRTUAL_ENV = $VIRTUAL_ENV

# TODO: Handle both environment variables and variables in global scope
$global:_OLD_VIRTUAL_PATH = $env:PATH
$env:PATH = "$env:VIRTUAL_ENV/Scripts;" + $env:PATH
if (test-path env:PYTHONHOME) {
    $global:_OLD_PYTHONHOME = $env:PYTHONHOME
    remove-item env:PYTHONHOME
}

Switch-DefaultPython

function global:_old_virtual_prompt { "" }
$function:_old_virtual_prompt = $function:prompt
function global:prompt {
    # Add a prefix to the current prompt, but don't discard it.
    write-host "($(split-path $env:VIRTUAL_ENV -leaf))" -nonewline
    & $function:_old_virtual_prompt
}

function global:deactivate ( [switch] $NonDestructive ) {

    $venv = split-path $env:VIRTUAL_ENV -leaf
    [void] (New-Event -SourceIdentifier 'VirtualEnvWrapper.PreDeactivateVirtualEnv' -eventarguments $venv)
    # RunHook "pre_deactivate"
    if ( test-path variable:_OLD_VIRTUAL_PATH ) {
        $env:PATH = $variable:_OLD_VIRTUAL_PATH
        remove-variable "_OLD_VIRTUAL_PATH" -scope global
    }

    if ( test-path env:PYTHONHOME ) {
        $env:PYTHONHOME = $env:_OLD_PYTHONHOME
        remove-item env:_OLD_PYTHONHOME
    }

    if ( test-path function:_old_virtual_prompt ) {
        $function:prompt = $function:_old_virtual_prompt
        remove-item function:\_old_virtual_prompt
    }

    if ($env:VIRTUAL_ENV) {
        $old_env = split-path $env:VIRTUAL_ENV -leaf
        remove-item env:VIRTUAL_ENV -erroraction silentlycontinue
        [void] (New-Event -SourceIdentifier 'VirtualenvWrapper.PostDeactivateVirtualEnv' -EventArguments $old_env)
        # RunHook "post_deactivate" $old_env
    }

    Switch-DefaultPython

    if ( !$NonDestructive ) {
        # SELF DESTRUCT!
        remove-item function:deactivate
    }
}
'@

function add_posh_to_virtualenv {
    param([string] $TargetPath)

    if (test-path "$TargetPath/Scripts") {
        Set-Content "$TargetPath/Scripts/activate.ps1" `
                    $ACTIVATE_SCRIPT_TEMPLATE `
                    -encoding "UTF8"
        write-host "Added activation script por Powershell to $TargetPath\Scripts."
    }
    else {
        Write-Warning "Couldn't copy PoSh activate script to new virtual environment."
    }
}

function getCurrentPythonExe { resolve-path (@(get-command "python.exe")[0]).Path }
function getCurrentPythonWExe { resolve-path (@(get-command "pythonw.exe")[0]).Path }

function switchPythonFTypeOpenCmd
{

    $HKCU_SOFT_CLASS = "HKCU:/Software/Classes"

    if (-not(test-path "$HKCU_SOFT_CLASS/Python.File/shell/open/command"))
    {
        new-item "$HKCU_SOFT_CLASS/Python.File/shell/open/command" -Force > $null
        set-itemproperty -path "$HKCU_SOFT_CLASS/Python.File/shell/open" -name "(default)" -value "Open"
    }
    if (-not(test-path "$HKCU_SOFT_CLASS/Python.NoConFile/shell/open/command"))
    {
        new-item "$HKCU_SOFT_CLASS/Python.NoConFile/shell/open/command" -Force > $null
        set-itemproperty -path "$HKCU_SOFT_CLASS/Python.NoConFile/shell/open" -name "(default)" -value "Open"
    }
    if (-not(test-path "$HKCU_SOFT_CLASS/Python.CompiledFile/shell/open/command"))
    {
        new-item "$HKCU_SOFT_CLASS/Python.CompiledFile/shell/open/command" -Force > $null
        set-itemproperty -path "$HKCU_SOFT_CLASS/Python.CompiledFile/shell/open" -name "(default)" -value "Open"
    }

    $currPython = getCurrentPythonExe
    $currPythonW = getCurrentPythonWExe
    set-itemproperty -path "$HKCU_SOFT_CLASS/Python.File/shell/open/command" -name "(default)" -value "`"$currPython`" `"%1`" %*"
    set-itemproperty -path "$HKCU_SOFT_CLASS/Python.CompiledFile/shell/open/command" -name "(default)" -value "`"$currPython`" `"%1`" %*"
    set-itemproperty -path "$HKCU_SOFT_CLASS/Python.NoConFile/shell/open/command" -name "(default)" -value "`"$currPythonW`" `"%1`" %*"
}

function switchPythonCore
{
    $currPython = getCurrentPythonExe
    $currPythonW = getCurrentPythonWExe
    $pyVer = & { $OFS = ""; "$((& "python.exe" "-V" 2>&1).exception.message.split(" ")[1][0..2])" }
    $pyArch = $(& "python.exe" -c 'import platform; print platform.architecture()[0]')
    $pyRegRoot = "HKCU\Software\Python\PythonCore"
    $regView = $null

    # Python installed for current user stays in HKCU irrespective of architecture
    $null = & "reg.exe" "query" "$pyRegRoot\$pyVer\InstallPath" 2> $null
    if ($lastExitCode -ne 0)
    {
        if ($pyArch -eq "32bit")
        {
            $regView = "/reg:32"
        }

        # System wide python install goes into architecture specific registry in HKLM
        $pyRegRoot = "HKLM\Software\Python\PythonCore"
        $null = & "reg.exe" "query" "$pyRegRoot\$pyVer\InstallPath" "$regView" 2> $null
        if ($lastExitCode -ne 0)
        {
            throw "Unable to locate python install path from registry. Is python installed?"
        }
    }

    if ($currPython -like "*Scripts*")
    {
        $pyBase = resolve-path "$(split-path $currPython -parent)/.."
    }
    else
    {
        $pyBase = resolve-path (split-path $currPython -parent)
    }

    $null = & 'reg.exe' 'add' "$pyRegRoot\$pyVer\InstallPath" '/ve' '/d' "$pyBase" '/t' 'REG_SZ' "$regView" '/f'
    $null = & 'reg.exe' 'add' "$pyRegRoot\$pyVer\PythonPath" '/ve' '/d' "$pyBase\Lib;$pyBase\DLLs;$pyBase\Lib\lib-tk" '/t' 'REG_SZ' "$regView" '/f'
}

function Switch-DefaultPython
{
<#
    .SYNOPSIS
    Sets the default python interpreter to the currently active virtualenv. This
    way you can run scripts like so:

        ./myscripts.py

    Otherwise you have to run them like this:

        python ./myscripts.py
#>
    switchPythonFTypeOpenCmd
    switchPythonCore
}
