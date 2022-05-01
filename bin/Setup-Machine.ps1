# Install scoop packages
#
scoop install git
scoop bucket add extras
scoop bucket add versions
scoop bucket add dodorz https://github.com/dodorz/scoop.git
scoop bucket add nerd-fonts https://github.com/matthewjberger/scoop-nerd-fonts

# Fetch windows configuration
#
cd ~
git init
git remote add origin https://github.com/codito/configs-win.git
git fetch origin
git checkout -t origin/master
git submodule init
git submodule update

# Install apps
#
cat ~\.config\scoop\apps.txt | % {
    scoop install $_
}

# Setup vim
#
cmd /c mklink %userprofile%\_vimrc %userprofile%\vimfiles\vimrc
cmd /c mklink %userprofile%\_gvimrc %userprofile%\vimfiles\gvimrc
mkdir ~/vimfiles/sessions
mkdir ~/vimfiles/tmp

# Setup config and data directories
mkdir ~/.local/share

# Setup git status cache
#
. $Profile.CurrentUserAllHosts
