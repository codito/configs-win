Windows configuration files
===========

## Bare metal box
On a powershell command prompt:
```powershell
iex (new-object net.webclient).DownloadString('https://get.scoop.sh')
iex (new-object net.webclient).DownloadString('https://raw.githubusercontent.com/codito/configs-win/master/bin/Setup-Machine.ps1')
```

## Installation
On a powershell command prompt:
```powershell
cd ~
git init
git remote add origin https://github.com/codito/configs-win.git
git fetch origin
git checkout -t origin/master
git submodule update --init

# VIM
cmd /c mklink %userprofile%\_vimrc %userprofile%\vimfiles\vimrc
cmd /c mklink %userprofile%\_gvimrc %userprofile%\vimfiles\gvimrc
```

Enjoy!
