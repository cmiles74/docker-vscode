.Net Development Environment
============================

You can pull this image from Docker Hub.

    docker pull cmiles74/docker-vscode

After much grinding and gnashing of teeth, I finally gave up on getting the .Net
packages up-and-running on my Arch Linux machine. It just wasn't working and it
was far too much of an uphill battle. This Docker image contains all of the same
tools, but wrapped up in an Ubuntu Server installation. Even so, the image is
still way too big; if you have any tips that might help me slim it down, please
let me know!

This image contains...

* Ubuntu Server 14.04 (Trusty)
* The latest Visual Studio Code release
* The latest Emacs release, with Spacemacs + Javascript
* The older .Net DNVM tools
* A New-ish .Net CLI tools
* OmniSharp Roslyn
* The latest Mono 
* The latest NPM, ready to install packages without root
* The latest Git
* The Hack font and Flat Plat GTK 2+3 theme
* URXVT

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
      -e DISPLAY=unix${DISPLAY} \
      -p 5000:5000 \
      --device /dev/snd \
      --name myproject-vscode \      
      --entrypoint "/bin/bash" \
      cmiles74/vscode

    docker exec discowiki-vscode /developer/bin/start-vscode
    docker exec discowiki-vscode /developer/bin/start-emacs

You can place this script in your project directory and run it right from there.
It will map in the project files, your Visual Studio Code settings from your
home directory, allow X11 access to your host environment and map in your
display and sound. Lastly, it will launch Visual Studio Code and Emacs.

Once it's launched, there are a couple setup tasks that I haven't yet automated
into the image. 

### Get a Terminal Session

From inside Visual Studio Code, press Control-Shift-C to bring up a console
window. ;-)

### Install a DNVM Runtime

DNVM installs itself as a set of Bash functions; it comes with the image.
However there is no DNX selected. To setup the Mono DNX, run the following:

    dnvm upgrade -r mono 
    
That's it! You will need to restart OmniSharp inside Visual Studio Code to pick
up the new DNX. Type Control-Shift-P to open the Command Palette and type "Omni"
and then choose "OmniSharp: Restart OmniSharp". 

### Additional Packages for Emacs

If you're using Emacs, you'll want to install tern, js-beautify and jshint with
NPM. These modules are used to support the Emacs Javascript mode. 

If you're working with React, you'll want to install eslint, babel-eslint and
eslint-plugin-react with NPM. These are used to support the React mode. Check
out the
[Spacemacs React documentation page](https://github.com/syl20bnr/spacemacs/tree/master/layers/%2Bframeworks/react)
for more information.

About DotNet ClI
----------------

This image comes with a version of the DotNet CLI that can successfully compile
OmniSharp Roslyn. I couldn't get it working with a .Net Core MVC application,
even the stock examples on the
[sample website](https://github.com/aspnet/cli-samples) had an issue where they
couldn't find the entrypoint. Your mileage may vary. :-)

To get OmniSharp Roslyn working in Visual Studio Code, add the following to your
user or workspace settings file.

    "csharp.omnisharp": "/developer/omnisharp-roslyn/artifacts/publish/<runtime id>/<target framework>/"
    

