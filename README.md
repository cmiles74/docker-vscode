.Net Development Environment
============================

You can pull this image from Docker Hub.

    docker pull cmiles74/docker-vscode

After much grinding and gnashing of teeth, I finally gave up on getting the .Net
packages up-and-running on my Arch Linux machine. It just wasn't working and it
was far too much of an uphill battle. This Docker image contains all of the same
tools, but wrapped up in an Debian Jesse installation. Even so, the image is
still way too big; if you have any tips that might help me slim it down, please
let me know!

This image contains...

* Linux, Debian Jesse
* The latest Visual Studio Code release
* The latest Emacs release, with Spacemacs + Javascript
* A New-ish .Net CLI tools
* Mono 
* The latest 4.x NPM, ready to install packages without root
* Git
* The Hack font and Flat Plat GTK 2+3 theme
* Firefox

Port 5000 is exposed, that is the default port used when running .Net
applications. The following mount points are also exposed.

* /developer/.config/Code
* /developer/.vscode
* /developer/project
* /developer/.ssh
      
The first two can be mapped into your home directory (to save settings across
all projects) or somewhere else (maybe your project folder). The last should be
mapped to your .Net project's source code directory. You can map in your .ssh
keys and configuration as well.

To be clear, this image is based on the .Net Core Docker image releasd by
Microsoft.

Running the Image
-----------------

When you're ready to run the image, you will probably want to write a little
script to handle starting up the container and launching applications. Here's
one that will do what you want.

    #!/bin/bash

    # allow X11 access
    xhost +local:docker

    # start vscode
    docker run -it \
      -d \
      -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
      -v ${PWD}:/developer/project \
      -v ${HOME}/.vscode:/developer/.vscode \
      -v ${HOME}/.config/Code:/developer/.config/Code \
      -v ${HOME}/.ssh:/developer/.ssh \
      -v ${HOME}/.gitconfig:/developer/.gitconfig \
      -v ${SSH_AUTH_SOCK}:/ssh_auth_sock \
      -e SSH_AUTH_SOCK=/ssh_auth_sock \
      -e DISPLAY=unix${DISPLAY} \
      -p 5000:5000 \
      --device /dev/snd \
      --name myproject-vscode \
      --entrypoint "/bin/bash" \
      cmiles74/docker-vscode

    docker exec discowiki-vscode /developer/bin/start-vscode
    docker exec discowiki-vscode /developer/bin/start-emacs

You can place this script in your project directory and run it right from there.
It will map in the project files, your Visual Studio Code settings from your
home directory, allow X11 access to your host environment and map in your
display and sound. Lastly, it will launch Visual Studio Code and Emacs.

Once it's launched, there are a couple setup tasks that I haven't yet automated
into the image. 

### Get a Terminal Session

Visual Studio Code now has an integrated terminal, you can toggle it's
visibility from under the "View" menu. By default, terminal sessions do not read
".bash_profile" and so they won't be able to see binaries installed by NPM. To
remedy this, open your "User Settings" (from under "Preferences") and add one of
the following:

    // Linux
    "terminal.integrated.shellArgs.linux": ["-l"]

    // OS X
    "terminal.integrated.shellArgs.osx": ["-l"]

### Additional Packages for Emacs

If you're using Emacs, you'll want to install tern, js-beautify and jshint with
NPM. These modules are used to support the Emacs Javascript mode. 

If you're working with React, you'll want to install eslint, babel-eslint and
eslint-plugin-react with NPM. These are used to support the React mode. Check
out the
[Spacemacs React documentation page](https://github.com/syl20bnr/spacemacs/tree/master/layers/%2Bframeworks/react)
for more information.

### Firefox

Firefox is included with this image to support the opening of web links from
inside Visual Studio Code. For instance, if you choose "Release Notes" from
under the "Help" menu, Code will attempt to open the URL with "xdg-open". To
make this all work, xdg-open is acutally a soft link to the Firefox binary (I
didn't want to install and XDG compliant desktop environment).

Presently the multi-process (electrolysis) version of Firefox is super crashy
under Docker. If you're using Firefox often, open the "Preferences" and uncheck
the "Enable multi-process Firefox Developer Edition" option.

If you already have Firefox running, the Firefox binary will detect this and it
will open the URL in your running (outside of Docker) Firefox instance. This is
probably the best way to go.

Anyway, with all of this setup and working, you can launch a "Web" debug session
and actually view the site in Firefox. If you'd like to use another browser,
feel free to customize the Docker script.

