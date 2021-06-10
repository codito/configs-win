# Install scoop packages
#
scoop install git
scoop bucket add extras
scoop bucket add dodorz https://github.com/dodorz/scoop.git
scoop bucket add nerd-fonts https://github.com/matthewjberger/scoop-nerd-fonts

scoop install sudo
scoop install 7zip
scoop install ag
scoop install autojump-rs
scoop install conemu
sudo scoop install jetbrains-mono jetbrainsmono-nf
scoop install python
scoop install starship
scoop install sysinternals
scoop install vim-tux

# Fetch windows configuration
#
cd ~
git init
git remote add origin https://github.com/codito/configs-win.git
git fetch origin
git checkout -t origin/master
git submodule init
git submodule update

# Setup vim
#
cmd /c mklink %userprofile%\_vimrc %userprofile%\vimfiles\vimrc
cmd /c mklink %userprofile%\_gvimrc %userprofile%\vimfiles\gvimrc
mkdir ~/vimfiles/sessions
mkdir ~/vimfiles/tmp

# Setup git status cache
#
. $Profile.CurrentUserAllHosts
