FROM ubuntu:16.04

LABEL maintainer="nandkeypull@outlook.com"

# Prevent tz setting from hanging build
ARG DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 && \
    apt update -y \
    && apt upgrade -y \
    && apt install -y socat gdb gdb-multiarch libc6-dbg libc6-dbg:i386 git binutils gcc-multilib g++-multilib curl wget make libssl-dev build-essential ruby ruby-dev radare2 netcat tmux nasm ltrace strace vim python3 python3-pip

RUN python3 -m pip install -U pip && \
    python3 -m pip install --no-cache-dir \
    ropgadget \
    pwntools \
    ropper \
    unicorn \
    keystone-engine \
    capstone

# Install tmux from source
RUN apt update \
    && apt -y install --no-install-recommends libevent-dev libncurses-dev jq curl wget git xclip \
    && apt clean

RUN TMUX_VERSION=$(curl -s https://api.github.com/repos/tmux/tmux/releases/latest | jq -r .tag_name) \
    && wget https://github.com/tmux/tmux/releases/download/$TMUX_VERSION/tmux-$TMUX_VERSION.tar.gz \
    && tar zxf tmux-$TMUX_VERSION.tar.gz \
    && cd tmux-$TMUX_VERSION \
    && ./configure && make && make install \
    && cd .. \
    && rm -rf tmux-$TMUX_VERSION* \
    && echo "tmux hold" | dpkg --set-selections # disable tmux update from apt \
    && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

RUN git clone --depth 1 https://github.com/pwndbg/pwndbg ~/pwndbg && \
    cd ~/pwndbg && chmod +x setup.sh && ./setup.sh

RUN gem install one_gadget seccomp-tools

# Configuration
RUN ln -s /usr/bin/python3 /usr/bin/python && \
    echo "source ~/.pwn_funcs" >> ~/.bashrc && \
    echo "alias .p='source ~/.pwn_funcs'" >> ~/.bashrc && \
    mkdir /root/HeapLAB

RUN mkdir ~/work
WORKDIR /root/work

EXPOSE 9999

ENTRYPOINT ["/bin/bash"]
