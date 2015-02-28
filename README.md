Windows configuration files
===========

## Installation
On a powershell command prompt:
```
$ cd ~
$ git init
$ git remote add origin https://github.com/codito/configs-win.git
$ git fetch origin
$ git checkout -t origin/master
$ git submodule foreach git submodule update --init

# VIM
$ cmd /c mklink %userprofile%\_vimrc %userprofile%\vimfiles\vimrc
```

Enjoy!
