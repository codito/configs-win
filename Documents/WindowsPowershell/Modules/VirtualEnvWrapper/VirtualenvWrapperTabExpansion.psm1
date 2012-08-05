<#
    Provides tab expansion functionalty for virtualenvwrapper.

    Should work with PowerTab.
    XXX Detect presence of PowerTab and add handler.
#>


#==============================================================================
# Ensure the old environment is restored when we exit. (Based on PowerTab.)
#------------------------------------------------------------------------------
$_oldTabExpansion = Get-Content Function:TabExpansion

$module = $MyInvocation.MyCommand.ScriptBlock.Module 
$module.OnRemove = {
    Set-Content Function:\TabExpansion -Value $_oldTabExpansion
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

filter LetVirtualEnvsThru {
<# Weak test to filter out dirs not resembling a virtualenv.
#>
    $_ | where-object {
            $_.PSIsContainer -and `
            (test-path (join-path $_.fullname 'Scripts/activate.ps1'))
            }
}

function GetVirtualEnvCompletions {
    param([string]$line, [string]$lastWord)

    # Filter by prefix.
    if ($lastWord)
    {
        get-childitem $env:WORKON_HOME | `
                        LetVirtualEnvsThru | `
                                where-object { 
                                    $_.name -like "$lastWord*"
                                    } | select-object -expandproperty name
        return
    }
    
    # No prefix, so we return all.
    get-childitem $env:WORKON_HOME | `
                    LetVirtualEnvsThru | `
                        select-object -expandproperty name
}


$VirtualEnvWrapperTabExpansion = {
    param($line, $lastWord)

    switch -regex ($line) {
        "^(.*[\s;])?(workon|rmvirtualenv|(remove|set)-virtualenvironment)\s+[^\s]*$" {
            GetVirtualEnvCompletions -Line $line -LastWord $lastWord
            break
        }
        default {
            & $_oldTabExpansion $line $lastWord
        }
    }
}

$function:TabExpansion = $VirtualEnvWrapperTabExpansion
