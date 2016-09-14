from phusion/baseimage

# get add-apt-repository
run apt-get update
run apt-get -y --no-install-recommends install software-properties-common

# add mono feed
run apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
run echo "deb http://download.mono-project.com/repo/debian wheezy main" | tee /etc/apt/sources.list.d/mono-xamarin.list

# add nodejs ppa
run curl -sL https://deb.nodesource.com/setup | bash -

# add emacs ppa
run add-apt-repository ppa:ubuntu-elisp/ppa

# add git ppa
run add-apt-repository ppa:git-core/ppa

# update apt cache
run apt-get update

# vscode dependencies
run apt-get -y --no-install-recommends install libgtk2.0-0 libgtk-3-0 libpango-1.0-0 libcairo2 libfontconfig1 libgconf2-4 libnss3 libasound2 libxtst6 unzip libglib2.0-bin libcanberra-gtk-module libgl1-mesa-glx mono-complete curl build-essential gettext libstdc++6 software-properties-common wget git xterm automake libtool autogen rxvt-unicode-256color nodejs libnotify-bin aspell aspell-en htop libunwind8-dev

# emacs dependencies
run apt-get -y build-dep emacs24-lucid

# install libuv
workdir /root
run wget https://github.com/libuv/libuv/archive/v1.4.2.tar.gz
run tar -zxvf v1.4.2.tar.gz
workdir /root/libuv-1.4.2
run sh /root/libuv-1.4.2/autogen.sh
run /root/libuv-1.4.2/configure
run make 
run make install
workdir /root
run rm -rf libuv-1.4.2
run rm -rf v1.4.2.tar.gz
run ldconfig

# install emacs
run wget http://ftp.gnu.org/gnu/emacs/emacs-24.5.tar.gz
run tar -zxvf emacs-24.5.tar.gz
workdir /root/emacs-24.5
run /root/emacs-24.5/configure
run make
run make install
workdir /root
run rm -rf emacs-24.5

# use urxvt instead of xterm
run mv /usr/bin/xterm /usr/bin/xterm.bak
run ln -s /usr/bin/urxvt /usr/bin/xterm

# install dotnet core
run curl -sSL -o dotnet.tar.gz https://go.microsoft.com/fwlink/?LinkID=827530
run mkdir -p /opt/dotnet && sudo tar zxf dotnet.tar.gz -C /opt/dotnet
rnu ln -s /opt/dotnet/dotnet /usr/local/bin

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

# install omnisharp roslyn
run git clone https://github.com/OmniSharp/omnisharp-roslyn.git
workdir /developer/omnisharp-roslyn
run git fetch
run git checkout dev
run /developer/omnisharp-roslyn/build.sh
workdir /developer

# fix developer permissions
run chmod +x /developer/bin/*
run chown -R developer:developer /developer
user developer

# install dnvm and dnx
# run wget --no-cache https://raw.githubusercontent.com/aspnet/Home/dev/dnvminstall.sh
# run chmod +x /developer/dnvminstall.sh
# run /developer/dnvminstall.sh
# run rm /developer/dnvminstall.sh
# user root
# run cat /developer/.bash_profile >> /etc/bash.bashrc
# user developer

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

