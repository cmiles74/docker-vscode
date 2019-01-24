from microsoft/dotnet:latest
#from cmiles74/dotnet:latest

# get add-apt-repository
run apt-get update
run apt-get -y --no-install-recommends install software-properties-common curl apt-transport-https

# add SQL Server tools PPA
# run curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
# run curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | tee /etc/apt/sources.list.d/msprod.list

# add nodejs ppa
run curl -sL https://deb.nodesource.com/setup_8.x | bash -

# update apt cache
run apt-get update

# vscode dependencies
run apt-get -y --no-install-recommends install libc6-dev libgtk2.0-0 libgtk-3-0 libpango-1.0-0 libcairo2 libfontconfig1 libgconf2-4 libnss3 libasound2 libxtst6 unzip libglib2.0-bin libcanberra-gtk-module libgl1-mesa-glx curl build-essential gettext libstdc++6 software-properties-common wget git xterm automake libtool autogen nodejs libnotify-bin aspell aspell-en htop git emacs25 mono-complete gvfs-bin libxss1 rxvt-unicode-256color x11-xserver-utils sudo vim libxkbfile1

# MS SQL Server tools
#
# This doesn't work because it makes you agree to a license agreement. I've
# tried "yes" but to no avail.
#
# run apt-get install mssql-tools

# update npm
run npm install npm -g

# install vscode
run wget -O vscode-amd64.deb  https://go.microsoft.com/fwlink/?LinkID=760868
run dpkg -i vscode-amd64.deb
run rm vscode-amd64.deb

# install flat plat theme
run wget 'https://github.com/nana-4/Flat-Plat/releases/download/3.20.20160404/Flat-Plat-3.20.20160404.tar.gz'
run tar -xf Flat-Plat*
run mv Flat-Plat /usr/share/themes
run rm Flat-Plat*gz
run mv /usr/share/themes/Default /usr/share/themes/Default.bak
run ln -s /usr/share/themes/Flat-Plat /usr/share/themes/Default

# install hack font
run wget 'https://github.com/chrissimpkins/Hack/releases/download/v2.020/Hack-v2_020-ttf.zip'
run unzip Hack*.zip
run mkdir /usr/share/fonts/truetype/Hack
run mv Hack* /usr/share/fonts/truetype/Hack
run fc-cache -f -v

# create our developer user
workdir /root
run groupadd -r developer -g 1000
run useradd -u 1000 -r -g developer -d /developer -s /bin/bash -c "Software Developer" developer
copy /developer /developer
workdir /developer

# default browser firefox
run ln -s /developer/.local/share/firefox/firefox /bin/xdg-open

# enable sudo for developer
run echo "developer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/developer

# fix developer permissions
run chmod +x /developer/bin/*
run chown -R developer:developer /developer
user developer

# install firefox
run mkdir Applications
#run wget "https://download.mozilla.org/?product=firefox-aurora-latest-ssl&os=linux64&lang=en-US" -O firefox.tar.bz2
run wget "https://ftp.mozilla.org/pub/firefox/nightly/2016/06/2016-06-30-00-40-07-mozilla-aurora/firefox-49.0a2.en-US.linux-x86_64.tar.bz2" -O firefox.tar.bz2
run tar -xf firefox.tar.bz2
run mv firefox .local/share
run rm firefox.tar.bz2

# links for firefox
run ln -s /developer/.local/share/firefox/firefox /developer/bin/x-www-browser
run ln -s /developer/.local/share/firefox/firefox /developer/bin/gnome-www-browser

# copy in test project
copy project /developer/project
workdir /developer/project

# setup our ports
expose 5000
expose 3000
expose 3001

# install spacemacs
user developer
workdir /developer
run git clone --recursive https://github.com/syl20bnr/spacemacs ~/.emacs.d

# set environment variables
env PATH /developer/.npm/bin:$PATH
env NODE_PATH /developer/.npm/lib/node_modules:$NODE_PATH
env BROWSER /developer/.local/share/firefox/firefox-bin
env SHELL /bin/bash

# mount points
volume ["/developer/.config/Code"]
volume ["/developer/.vscode"]
volume ["/developer/.ssh"]
volume ["/developer/project"]

# start vscode
entrypoint ["/developer/bin/start-shell"]

