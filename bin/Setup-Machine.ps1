# Install chocolatey packages
#
Write-Host "Setup: Installing choco packages..."
choco install -y vim
choco install -y conemu
choco install -y sysinternals
choco install -y 7zip
choco install -y foobar2000
choco install -y f.lux
choco install -y git
choco install -y gittfs
choco install -y google-chrome-x64

choco install -y python3-x86_32

choco install -y stylecop
choco install -y ilspy
choco install -y resharper
choco install -y insomnia
Write-Host "Setup: Installing choco packages: Complete."

# Setup vim
#
cd ~
git init
git remote add origin https://github.com/codito/configs-win.git
git fetch origin
git checkout -t origin/master
git submodule update --init

cmd /c mklink %userprofile%\_vimrc %userprofile%\vimfiles\vimrc
cmd /c mklink %userprofile%\_gvimrc %userprofile%\vimfiles\gvimrc
mkdir d:\backups
