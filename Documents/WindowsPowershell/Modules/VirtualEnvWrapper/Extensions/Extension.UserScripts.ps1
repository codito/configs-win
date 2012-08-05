# Used by events. Must be global so that the Register-EngineEvent -Actions
# finds it when they are executed in the global scope. 
function global:VEW_RunInSubProcess {
    param($Script)

    start-process 'powershell.exe' `
                                -nonewwindow `
                                -arg '-Nologo', `
                                     '-NoProfile', `
                                     # Between quotes so that paths with spaces work.
                                     '-File', "`"$Script`""
}


& {         
    $GenerateGlobalHookScripts = {
    # Closures in -Action values for Engine Events won't do what you expect, so
    # state must go in the same scope as the scriptblock to be run as action.
    # http://stackoverflow.com/questions/6905305/how-to-use-getnewclosure-with-the-action-value-for-an-engineevent
        $GLOBAL_HOOKS = (
            'VEW_PreMakeVirtualEnv.ps1',
            'VEW_PostMakeVirtualEnv.ps1',
            'VEW_PreRemoveVirtualEnv.ps1',
            'VEW_PostRemoveVirtualEnv.ps1',
            'VEW_PreActivateVirtualEnv.ps1',
            'VEW_PostActivateVirtualEnv.ps1',
            'VEW_PreDeactivateVirtualEnv.ps1',
            'VEW_PostDeactivateVirtualEnv.ps1'
            )

        foreach ($x in $GLOBAL_HOOKS)
        {
            [void] (New-Item -itemtype 'file' -path (join-path $env:WORKON_HOME $x))
        }
    }

    $GenerateLocalHookScripts = {
        $LOCAL_HOOKS = (
            'VEW_PreActivateVirtualEnv.ps1',
            'VEW_PostActivateVirtualEnv.ps1',
            'VEW_PreDeactivateVirtualEnv.ps1',
            'VEW_PostDeactivateVirtualEnv.ps1'
            )

        foreach ($x in $LOCAL_HOOKS)
        {
            [void] (New-Item -itemtype 'file' `
                                -path (join-path $env:WORKON_HOME "$($args[0])/Scripts/$x") `
                                -erroraction 'SilentlyContinue' -force)
        }
    }


######### Global Hooks #########################################################

    $PreMakeVirtualEnvHook = {
        VEW_RunInSubProcess (join-path $env:WORKON_HOME 'VEW_PreMakeVirtualEnv.ps1')
        # start-job -scriptblock { (join-path $args[0] 'VEW_PreMakeVirtualEnv.ps1') } -argumentlist $env:WORKON_HOME
        # start-job -scriptblock { & $args[0] } -argumentlist (join-path $env:WORKON_HOME 'VEW_PreMakeVirtualEnv.ps1')
    }

    $PostMakeVirtualEnvHook = {
        & (join-path $env:WORKON_HOME 'VEW_PostMakeVirtualEnv.ps1')
    }

    $PreRemoveVirtualEnvHook = {
        VEW_RunInSubProcess (join-path $env:WORKON_HOME 'VEW_PreRemoveVirtualEnv.ps1')
    }

    $PostRemoveVirtualEnvHook = {
        VEW_RunInSubProcess (join-path $env:WORKON_HOME 'VEW_PostRemoveVirtualEnv.ps1')
    }

    $PreActivateVirtualEnvHook = {
        VEW_RunInSubProcess (join-path $env:WORKON_HOME 'VEW_PreActivateVirtualEnv.ps1')
    }

    $PostActivateVirtualEnvHook = {
        & (join-path $env:WORKON_HOME 'VEW_PostActivateVirtualEnv.ps1')
    }

    $PreDeactivateVirtualEnvHook = {
        & (join-path $env:WORKON_HOME 'VEW_PreDeactivateVirtualEnv.ps1')
    }

    $PostDeactivateVirtualEnvHook = {
        & (join-path $env:WORKON_HOME 'VEW_PostDeactivateVirtualEnv.ps1')
    }

# =============================================================================


######### Local Hooks #########################################################

    $PostDeactivateVirtualEnvHookLocal = {
        & (join-path $env:WORKON_HOME "$($event.sourceargs[0])/Scripts/VEW_PostDeactivateVirtualEnv.ps1")
    }

    $PreDeactivateVirtualEnvHookLocal = {
        & (join-path $env:VIRTUAL_ENV "Scripts/VEW_PreDeactivateVirtualEnv.ps1")
    }

    $PreActivateVirtualEnvHookLocal = {
        & (join-path $env:WORKON_HOME "$($event.sourceargs[0])/Scripts/VEW_PreActivateVirtualEnv.ps1")
    }

    $PostActivateVirtualEnvHookLocal = {
        & (join-path $env:VIRTUAL_ENV "/Scripts/VEW_PostActivateVirtualEnv.ps1")
    }

# =============================================================================


###### Register global hooks ##################################################

    [void] (register-engineevent -SourceIdentifier 'VirtualEnvWrapper.PreMakeVirtualEnv' `
                         -Action $PreMakeVirtualEnvHook)

    [void] (register-engineevent -SourceIdentifier 'VirtualEnvWrapper.PostMakeVirtualEnv' `
                         -Action $PostMakeVirtualEnvHook)

    [void] (register-engineevent -SourceIdentifier 'VirtualEnvWrapper.PreRemoveVirtualEnv' `
                         -Action $PreRemoveVirtualEnvHook)

    [void] (register-engineevent -SourceIdentifier 'VirtualEnvWrapper.PostRemoveVirtualEnv' `
                         -Action $PostRemoveVirtualEnvHook)

    [void] (register-engineevent -SourceIdentifier 'VirtualEnvWrapper.PreActivateVirtualEnv' `
                         -Action $PreActivateVirtualEnvHook)

    [void] (register-engineevent -SourceIdentifier 'VirtualEnvWrapper.PostActivateVirtualEnv' `
                         -Action $PostActivateVirtualEnvHook)

    [void] (register-engineevent -SourceIdentifier 'VirtualEnvWrapper.PreDeactivateVirtualEnv' `
                         -Action $PreDeactivateVirtualEnvHook)

    [void] (register-engineevent -SourceIdentifier 'VirtualEnvWrapper.PostDeactivateVirtualEnv' `
                         -Action $PostDeactivateVirtualEnvHook)

    [void] (register-engineevent -SourceIdentifier 'VirtualEnvWrapper.Initialize' `
                         -Action $GenerateGlobalHookScripts)

    [void] (register-engineevent -SourceIdentifier 'VirtualEnvWrapper.PreMakeVirtualEnv' `
                         -Action $GenerateLocalHookScripts)

#==============================================================================


###### Register local hooks ###################################################

    [void] (register-engineevent -SourceIdentifier 'VirtualEnvWrapper.PreDeactivateVirtualEnv' `
                         -Action $PreDeactivateVirtualEnvHookLocal)

    [void] (register-engineevent -SourceIdentifier 'VirtualEnvWrapper.PostDeactivateVirtualEnv' `
                         -Action $PostDeactivateVirtualEnvHookLocal)

    [void] (register-engineevent -SourceIdentifier 'VirtualEnvWrapper.PreActivateVirtualEnv' `
                         -Action $PreActivateVirtualEnvHookLocal)

    [void] (register-engineevent -SourceIdentifier 'VirtualEnvWrapper.PostActivateVirtualEnv' `
                         -Action $PostActivateVirtualEnvHookLocal)

#==============================================================================
}
