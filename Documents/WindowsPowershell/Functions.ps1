# Functions for PS
# Last Modified: 01/02/2022, 19:26:03 +0530

# Search utilities
function global:rgrep { ls -recurse -include $args[1] | grep $args[0] }
function global:rfind { ls -recurse -include $args[0] | % { $_.FullName } }

# File system utilities
function global:.. { cd.. }
function global:... { cd ..\.. }
function global:j {
    $dir = $args[0]
    if ([string]::IsNullOrEmpty($dir)) {
        $dir = "~"
    }
    elseif (!(Test-Path $args[0])) {
        $d = $(autojump $args)
        if ($d -ne ".") {
            $dir = $d
        }
    }

    pushd $dir
    autojump --add $(pwd).Path
}

function global:mklink { cmd /c mklink $args }
function global:ddiff($dir1, $dir2, $filePattern)
{
    $a = (ls $dir1 -recurse -include $filePattern)
    $b = (ls $dir2 -recurse -include $filePattern)
    $len = $a.Length

    $cnt = 0
    while ($cnt -lt $len)
    {
        fdiff $a[$cnt] $b[$cnt]
        $cnt++
    }
}

function global:fdiff($file1, $file2)
{
    $left = (cat $file1)
    $right = (cat $file2)

    write-host "Comparing $file1 : $file2"
    diff $left $right
}

# Git aliases, inspired from oh-my-zsh git plugin
function global:ga { git add $args }
function global:gb { git branch $args }
function global:gci { git commit $args }
function global:gco { git checkout $args }
function global:gcm { git checkout master }
function global:gd { git diff $args }
function global:glg { git log --stat --max-count=5 $args }
function global:glgg { git log --graph --max-count=5 $args }
function global:gst { git status $args }

# Visual Studio

function global:devps($version)
{
    $versionRange = "[$version,$([System.Double]$version+1))"
    $installPath = &"${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -version "$versionRange" -prerelease -property installationpath
    Import-Module (Join-Path $installPath "Common7\Tools\Microsoft.VisualStudio.DevShell.dll")
    Enter-VsDevShell -VsInstallPath $installPath -SkipAutomaticLocation
    [System.Console]::Title = "Visual Studio " + $version + " Windows Powershell"
}

function global:devcmd($version)
{
    $versionRange = "[$version,$([System.Double]$version+1))"
    $installPath = &"${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -version "$versionRange" -prerelease -property installationpath
    cmd.exe /k `"$installPath\Common7\Tools\VsDevCmd.bat`"
}

function global:b { msbuild $args }
function global:bm { msbuild /v:minimal $args }
function global:br { msbuild /v:minimal /t:rebuild $args }
function global:bre { msbuild /v:minimal /t:restore $args }
function global:bc { msbuild /v:minimal /t:clean $args }
