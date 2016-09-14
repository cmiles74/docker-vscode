from microsoft/dotnet:latest

# get add-apt-repository
run apt-get update
run apt-get -y --no-install-recommends install software-properties-common

# add nodejs ppa
run curl -sL https://deb.nodesource.com/setup_4.x | bash -

# update apt cache
run apt-get update

# vscode dependencies
run apt-get -y --no-install-recommends install libgtk2.0-0 libgtk-3-0 libpango-1.0-0 libcairo2 libfontconfig1 libgconf2-4 libnss3 libasound2 libxtst6 unzip libglib2.0-bin libcanberra-gtk-module libgl1-mesa-glx curl build-essential gettext libstdc++6 software-properties-common wget git xterm automake libtool autogen nodejs libnotify-bin aspell aspell-en htop git emacs mono-complete

# install vscode
run wget -O vscode-amd64.deb  https://go.microsoft.com/fwlink/?LinkID=760868
run dpkg -i vscode-amd64.deb
run rm vscode-amd64.deb

# install flat plat theme
run wget 'https://github.com/nana-4/Flat-Plat/releases/download/3.20.20160404/Flat-Plat-3.20.20160404.tar.gz'
run tar -zxvf Flat-Plat*
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
run useradd -u 1000 -r -g developer -d /developer -c "Software Developer" developer
copy /developer /developer
workdir /developer

# fix developer permissions
run chmod +x /developer/bin/*
run chown -R developer:developer /developer
user developer

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

# set path
run export PATH=$PATH:/developer/.npm/bin

# mount points
volume ["/developer/.config/Code"]
volume ["/developer/.vscode"]
volume ["/developer/.ssh"]
volume ["/developer/project"]

# start vscode
entrypoint ["/developer/bin/start-vscode"]

