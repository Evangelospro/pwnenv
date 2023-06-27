FROM ubuntu:23.04

# ----- Setup Enviornment ----- #
# get basics
USER root
ENV HOME /root
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
        apt-get upgrade -y  && \
        apt-get update && \
        apt-get install -y \
        lsd \
        locales \
        wget \
        curl \
        git \
        python3 \
        python3-pip \
        zsh \
        file \
        ltrace \
        strace \
        gdb \
        # build tools
        gcc \
        build-essential \
        make \
        clang \
        pkg-config \
        binutils-multiarch \
        # socket stuff
        # netcat \
        socat \
        # other
        nano \
        less

# Tools
RUN apt-get update && \
        apt-get install -y\
        ipython3\
        ruby\
        ruby-dev\
        # debugging
        libgmp-dev\
        texinfo\
        libc6-armel-cross\
        gcc-arm-linux-gnueabihf\
        gcc-10-arm-linux-gnueabi\
        gdb\
        gdbserver\
        gdb-multiarch\
        clangd\
        # ctfmate
        patchelf\
        elfutils

# IDK why this is needed
RUN rm /usr/lib/python3.11/EXTERNALLY-MANAGED

# RE tools
RUN python3 -m pip install --upgrade pip && \
        python3 -m pip install --user pwntools && \
        python3 -m pip install --user ptrlib && \
        python3 -m pip install --user ropper && \
        python3 -m pip install --user ROPGadget && \
        python3 -m pip install --user sagemath numpy

# gdb  debuginfod
RUN mkdir -p /etc/debuginfod/ && \
        echo "https://debuginfod.elfutils.org/" >> /etc/debuginfod/urls.urls

# pwninit
WORKDIR /usr/bin
RUN wget https://github.com/io12/pwninit/releases/download/3.3.0/pwninit && \
        chmod +x /usr/bin/pwninit

# configure python(s)
RUN python3 -m pip install --upgrade setuptools
ENV PATH ${HOME}/.local/bin:${PATH}

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH ${HOME}/.cargo/bin:${PATH}

COPY binaries /root/binaries
RUN chown -R root:root /root/binaries
RUN chmod +x /root/binaries/*

# /etc/zsh/zshenv
RUN echo 'export ZDOTDIR="$HOME/.config/zsh"' > /etc/zsh/zshenv

# Dotfiles(including gdb config)
RUN chsh -s $(which zsh)
COPY bw /usr/bin/bw
RUN chmod +x /usr/bin/bw
RUN wget -O /tmp/chezmoi.deb https://github.com/twpayne/chezmoi/releases/download/v2.34.2/chezmoi_2.34.2_linux_amd64.deb
RUN apt-get install -y /tmp/chezmoi.deb
RUN chezmoi init --apply Evangelospro
RUN pip install -r ~/.local/share/chezmoi/requirements.txt

# gdb
COPY locale.gen /etc/locale.gen
RUN locale-gen en_US.UTF-8
RUN git clone https://github.com/pwndbg/pwndbg.git ~/.config/gdb/pwndbg
RUN git clone https://github.com/longld/peda.git ~/.config/gdb/peda
RUN git clone https://github.com/alset0326/peda-arm.git ~/.config/gdb/peda-arm
RUN git clone https://github.com/hugsy/gef.git ~/.config/gdb/gef
RUN sed -i "s/^alias pwnsetup=.*/alias pwnsetup='\/root\/pwnsetup\/pwnsetup.py'/" ~/.config/zsh/aliases.zsh

# Drop into zsh
WORKDIR /root/binaries
RUN rm -rf /tmp/*
ENTRYPOINT [ "/usr/bin/zsh" ]