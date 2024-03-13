FROM debian:rc-buggy

ENV DEBIAN_FRONTEND=noninteractive \
    LV_BRANCH='release-1.3/neovim-0.9' \
    NODE_MAJOR=20 \
    GO_VERSION=1.22.0 \
    PATH=$PATH:/usr/local/go/bin:/usr/local/nvim/bin:/root/.local/bin:/root/.local/bin

RUN apt-get update && apt-get upgrade -y --no-install-recommends \
    && apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl sudo gnupg \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get install -y --no-install-recommends git make cmake gcc g++ python3 python3-pip python3-setuptools python3-wheel python3-dev zsh tmux \
    ninja-build unzip gettext software-properties-common silversearcher-ag fd-find nodejs shfmt \
    && rm -rf /var/lib/apt/lists/* && rm -rf /var/cache/apt/archives/* && rm -rf /tmp/*

RUN curl -LO https://dl.k8s.io/release/v1.29.2/bin/linux/amd64/kubectl \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

RUN curl -LO https://github.com/Hex-Techs/hexctl/releases/download/V0.1.7/hexctl_linux \
    && install -o root -g root -m 0755 hexctl_linux /usr/local/bin/hexctl

RUN curl -LO https://studygolang.com/dl/golang/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar xvzf go${GO_VERSION}.linux-amd64.tar.gz -C /usr/local

RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz \
    && tar xvzf nvim-linux64.tar.gz -C /usr/local && mv /usr/local/nvim-linux64 /usr/local/nvim \
    && git clone https://github.com/Fize/dotfiles.git /root/.dotfiles && mkdir -p ~/.config/lvim \
    && ln -s /root/.dotfiles/lvim-config.lua ~/.config/lvim/config.lua

WORKDIR /root
