FROM ubuntu:latest

# ----- Setup Enviornment ----- #
USER root
ENV HOME /root
ENV LANG en_US.utf8
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && \
        apt upgrade -y  && \
        apt install -y \
        lolcat \
        figlet \
        locales \
        wget \
        curl \
        git \
        golang \
        python3 \
        python3-pip \
        python3-venv \
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

# Fix lolcat
RUN ln -s /usr/games/lolcat /usr/bin/lolcat

# Tools
RUN apt install -y\
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

# /etc/zsh/zshenv
RUN echo 'export ZDOTDIR="$HOME/.config/zsh"' > /etc/zsh/zshenv

# Dotfiles(including gdb config)
RUN chsh -s $(which zsh)
COPY bw /usr/bin/bw
RUN chmod +x /usr/bin/bw
RUN sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply Evangelospro

# This will install dotfile related AND Hacker tools
RUN pip install -r ~/.local/share/chezmoi/requirements.txt --break-system

# gdb
COPY locale.gen /etc/locale.gen
RUN locale-gen en_US.UTF-8
# The below are already installed by chezmoi externals
# RUN git clone https://github.com/pwndbg/pwndbg.git ~/.config/gdb/pwndbg
# RUN git clone https://github.com/longld/peda.git ~/.config/gdb/peda
# RUN git clone https://github.com/alset0326/peda-arm.git ~/.config/gdb/peda-arm
# RUN git clone https://github.com/hugsy/gef.git ~/.config/gdb/gef

# pwn setup scripts
COPY pwnsetup /root/pwnsetup

# Autopwners
RUN git clone https://github.com/guyinatuxedo/remenissions /root/remenissions
RUN /root/remenissions/setup.sh

# Terminal binary
RUN wget https://github.com/wez/wezterm/releases/download/nightly/wezterm-nightly.Ubuntu22.04.deb -O /tmp/wezterm.deb
RUN apt install -y /tmp/wezterm.deb

# Drop into zsh
WORKDIR /root/data
RUN rm -rf /tmp/*
ENTRYPOINT [ "/usr/bin/zsh" ]
