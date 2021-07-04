# Functions for PS
# Last Modified: 04/07/2021, 19:13:07 India Standard Time

# Search utilities
function global:rgrep { ls -recurse -include $args[1] | grep $args[0] }
function global:rfind { ls -recurse -include $args[0] | % { $_.FullName } }

# System utilities
function global:disable-capslock
{
    & reg add "HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout" /v "Scancode Map" /t REG_BINARY /d "00,00,00,00,00,00,00,00,02,00,00,00,00,00,3a,00,00,00,00,00" /f
}
function global:enable-capslock
{
    & reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout" /v "Scancode Map" /f
}

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

# Resharper
function global:resume-resharper()
{
    & reg add HKCU\Software\JetBrains\ReSharper\v7.1\vs11.0 /v IsSuspended /t REG_SZ /d False /f
}

function global:suspend-resharper()
{
    & reg add HKCU\Software\JetBrains\ReSharper\v7.1\vs11.0 /v IsSuspended /t REG_SZ /d True /f
}

# Virtual environment for Python
function global:mkv
{
    param
    (
        [Parameter(Mandatory=$true)]
        [String] $Path,

        [Switch] $SystemSitePackages
    )

    $venvArgs = @("$env:USERPROFILE\bin\pyvenvex.py", "--symlinks", "--verbose")
    if ($SystemSitePackages) { $venvArgs += "--system-site-packages" }
    $venvArgs += $path
    & python $venvArgs
    Write-Host "Completed command: $venvArgs"
}

function global:cdv
{
    param
    (
        [Parameter(Mandatory=$true)]
        [String] $Path
    )

    if (-not (Test-Path $Path)) { Write-Host "Virtual environment path not found: $Path."; return }
    & $Path\Scripts\Activate.ps1
    Write-Host "Activated virtual environment from $path."
}

# Diffs multiple files in a directory selected by a pattern
# Incomplete
function global:mdiff($dir, $pattern)
{
    $fileContentHash = @{}
    $maxLines = 0

    # read all the files
    ls $dir -recurse -include $pattern |
    % {
        $fileName = $_
        $fContent = (cat $FileName)

        # create line wise hash which will contain the file and the line numbers
        # @{ Line1 = { file:line1; file2:line1; file3:line1 .. } }
        $lineCount = 1
        $fContent |
        % {
            $fileAndLine = $fileName+":"+$_
            $currentValue += ,$fileAndLine
            if ($fileContentHash.ContainsKey($lineCount))
            {
                # the key exists, so add the file:line to the value
                $currentValue = $fileContentHash.Item($lineCount)
                $currentValue += ,$fileAndLine
                $fileContentHash.Item($lineCount) = $currentValue
            }
            else
            {
                # add a key/value for this line number
                $fileContentHash.Add($lineCount, $currentValue)
            }

            $currentValue = $null
            $lineCount++
        }

        write-host "Parsed: $fileName"
    }

    # traverse through the hash and list the differences
    $fileContentHash
}
