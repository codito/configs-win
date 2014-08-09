# Visual Studio powershell helper script
# Based on http://www.tavaresstudios.com/Blog/post/The-last-vsvars32ps1-Ill-ever-need.aspx

function Get-Batchfile ($file)
{
    $cmd = "`"$file`" & set"
    cmd /c $cmd | Foreach-Object {
        if ($_.Contains('=')) {
            $p, $v = $_.split('=')
            Set-Item -path env:$p -value $v
        }
    }
}

function VsVars32($version)
{
    $key = "HKLM:SOFTWARE\Wow6432Node\Microsoft\VisualStudio\" + $version
    $VsKey = get-ItemProperty $key
    $VsInstallPath = [System.IO.Path]::GetDirectoryName($VsKey.InstallDir)
    $VsToolsDir = [System.IO.Path]::GetDirectoryName($VsInstallPath)
    $VsToolsDir = [System.IO.Path]::Combine($VsToolsDir, "Tools")
    $BatchFile = [System.IO.Path]::Combine($VsToolsDir, "vsvars32.bat")
    Get-Batchfile $BatchFile
    [System.Console]::Title = "Visual Studio " + $version + " Windows Powershell"
}

VsVars32("14.0")
# vim: set ft=powershell:
