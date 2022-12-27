# FROM archlinux:latest
FROM greyltc/archlinux-aur:paru

RUN pacman-key --init

RUN pacman -Syu --noconfirm base-devel git sudo

RUN useradd -m -s /bin/zsh hacker
RUN echo "hacker:hacker" | chpasswd
RUN usermod -aG wheel hacker
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# before becoming hacker copy the binaries and change permissions
COPY binaries /home/hacker/binaries
RUN chown -R hacker:hacker /home/hacker/binaries
RUN chmod +x /home/hacker/binaries/*

USER hacker
WORKDIR /home/hacker

# enable if using the non-aur image
# RUN git clone https://aur.archlinux.org/paru.git
# RUN cd paru && makepkg -si --noconfirm

# Install packages
RUN paru -Syu --noconfirm \
        curl \
        file \
        fzf \
        less \
        python3 \
        python-pip \
        unzip \
        vim \
        wget \ 
        make \
        gcc \
        radare2 \
        checksec \
        binwalk \
        strace \
        ltrace


RUN python3 -m pip install --upgrade pip
# Install ropper
RUN python3 -m pip install --upgrade keystone-engine ropper

# Install gef-pwndbg-peda Apogiatzis<3
RUN git clone https://github.com/apogiatzis/gdb-peda-pwndbg-gef
RUN cd gdb-peda-pwndbg-gef && ./install.sh

# Zsh + p10k
RUN git clone https://github.com/Evangelospro/Linux-Setup
WORKDIR /home/hacker/Linux-Setup
RUN chmod -R +x . && ./aur-setup.sh && ./install-scripts/zsh.sh --headless && ./install-scripts/hacking.sh
WORKDIR /home/hacker/binaries