<#
    .SYNOPSIS
    Project management extension for VirtualEnvWrapper.

    .DESCRIPTION
    Manages a project directory along a virtual environment. Do not use this
    file as a script. Place it in you VirtualEnvWrapper Extensions folder
    instead and it will be imported correctly.
#>

$script:thisDir = split-path $MyInvocation.MyCommand.Path -parent
# XXX This one shouldn't be needed if this was a module. We need to know where
# to find extensions (and templates).
$script:VEWRoot = split-path $script:thisDir -parent

# Define actions for event listeners.
###############################################################################
$GenerateGlobalHookScripts = {
    $GLOBAL_HOOKS = (
        'VEW_PreMakeProject.ps1',
        'VEW_PostMakeProject.ps1'

        # rmproject -- not implemented
        # 'VEW_PreRemoveProject.ps1',
        # 'VEW_PostRemoveProject.ps1'
        )

    foreach ($x in $GLOBAL_HOOKS)
    {
        [void] (New-Item -itemtype 'file' `
                            -path (join-path $env:WORKON_HOME $x) `
                            -erroraction 'SilentlyContinue' -force)
    }
}

$PreMakeVirtualEnvProjectHook = {
    VEW_RunInSubProcess "$env:WORKON_HOME/VEW_PreMakeProject.ps1" "$args"
}

$PostMakeVirtualEnvProjectHook = {
    & "$env:WORKON_HOME/VEW_PostMakeProject.ps1" "$args"
}
#==============================================================================

# Hook up actions to event listeners.
###############################################################################
[void] (register-engineevent -sourceidentifier "VirtualEnvWrapper.Project.PreMakeVirtualEnvProject" `
                        -action $PreMakeVirtualEnvProjectHook)

[void] (register-engineevent -sourceidentifier "VirtualEnvWrapper.Project.PostMakeVirtualEnvProject" `
                        -action $PostMakeVirtualEnvProjectHook)

[void] (register-engineevent -sourceidentifier "VirtualEnvWrapper.Initialize" `
                        -action $GenerateGlobalHookScripts)
#==============================================================================

# XXX We shouldn't need to define this as global (and the others either).
function global:VEW_Project_VerifyProjectHome {
    if (-not (test-path variable:ProjectHome)) {
        throw("You must set the `$ProjectHome variable to point to a directory.")
    }

    if (-not (test-path $ProjectHome)) {
        throw("Set `$ProjectHome to an existing directory.")
    }
}


function global:Set-VirtualEnvProject {
<#
    .SYNOPSIS
    Associates a directory with a virtual environment.

    .DESCRIPTION
    If no parameters are passed, associates the current directory with the
    active virtualenvironment. A virtual environment can only be associated
    with one folder.
#>
    param($Venv, $Project)

    if (-not $Venv) {
        $Venv = $env:VIRTUAL_ENV
    }

    if (!(test-path $venv)) {
        throw ("Can't find virtualenv.")
    }

    if (-not $Project) {
       $Project = $pwd.providerpath
    }

    if (!(test-path $project)) {
        throw("Can't find project directory.")
    }

    Write-Host "Setting project for $(split-path $Venv -leaf) to $Project"
    Set-Content "$Venv/.project" -value "$Project" -encoding "UTF8"
}


function global:New-VirtualEnvProject {
<#
    .SYNOPSIS
    Creates a new virtual environment and associates it with a new project
    folder.

    .DESCRIPTION
    You need to specify the name of the new virtual environment. The variable
    $ProjectHome must be set and point to an existing directory. This is where
    project folders are created.
#>
    param([string]$EnvName=$(throw("Need a name for the virtual environment.")),
          [string[]]$Templates=@())

    try {
        VEW_Project_VerifyProjectHome
    }
    catch {
        throw
    }

    if ((test-path "$ProjectHome/$EnvName")) {
        throw("Project $EnvName already exists.")
    }

    try {
        New-VirtualEnvironment $EnvName $args
    }
    catch {
        throw
    }

    [void] (New-Event -sourceidentifier "VirtualEnvWrapper.Project.PreMakeVirtualEnvProject" `
                -eventarguments $envName)

    write-host "Creating $ProjectHome/$EnvName"
    [void] (New-Item -ItemType 'directory' -Path "$ProjectHome/$EnvName")
    Set-VirtualEnvProject "$env:VIRTUAL_ENV" "$ProjectHome/$EnvName"

    Set-Location "$ProjectHome/$EnvName"

    if ($templates.count -gt 0 -and
        (!(test-path variable:VirtualenvWrapperTemplates)) -or
        ("$VirtualenvWrapperTemplates" -and !(test-path "$VirtualenvWrapperTemplates"))) {
            throw ("Set the `$VirtualenvWrapperTemplates variable to point to an existing directory containing the templates.")
    }

    foreach ($t in $templates) {
        $item = get-item (join-path $VirtualenvWrapperTemplates "Project.Template.$t.ps1") -erroraction "SilentlyContinue"
        if (!$item) {
            write-error "Template '$t' not found. Not applying."
            continue
        }

        # todo: implement ant test this
        write-host "Applying template $t..."
        & $item $envName
    }

    [void] (new-event -sourceidentifier "VirtualEnvWrapper.Project.PostMakeVirtualEnvProject" `
                -eventarguments $function)
}


function global:Set-LocationToProject {
<#
    .SYNOPSIS
    Changes the current directory to point to the active project folder.

    .DESCRIPTION
    An association of a folder and the active virtual environment must exist.
#>
    try {
        # Provided by VirtualEnvWrapper
        # XXX importing the same module from several files causes PS to crash?
        # XXX That's why the following two funcs are globals and not imported
        # XXX as part of a module.
        VerifyWorkonHome
        VerifyVirtualEnv
    }
    catch [System.IO.IOException] {
        throw
    }

    if (!(test-path "$env:VIRTUAL_ENV/.project")) {
        throw("No project set in $env:VIRTUAL_ENV/.project")
    }

    $projectDir = get-content "$env:VIRTUAL_ENV/.project"
    if (!(test-path $projectDir)) {
       throw("Project directory $projectDir does not exist.")
    }

    set-location $projectDir
}


new-alias -name 'cdproject' -value Set-LocationToProject -scope "Global"
new-alias -name 'mkproject' -value New-VirtualEnvProject -scope "Global"
new-alias -name 'setvirtualenvproject' -value Set-VirtualEnvProject -scope "Global"
