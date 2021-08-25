ARG IMAGE_BASE=python:3.6
FROM $IMAGE_BASE

ENV DEBIAN_FRONTEND=noninteractive
ENV IS_DOCKER=1

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

ARG UNAME=docker
ENV HOME=/home/$UNAME


SHELL [ "/bin/bash", "-c" ]

COPY etc/odbcinst.ini /etc/odbcinst.ini

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# DB CONFIGURATION
RUN mkdir -p ~/.ssh && chmod 0700 ~/.ssh

# git secret
RUN echo 'deb https://gitsecret.jfrog.io/artifactory/git-secret-deb git-secret main' >> /etc/apt/sources.list \
    && wget -qO - 'https://gitsecret.jfrog.io/artifactory/api/gpg/key/public' | apt-key add -

ARG APT_LIST
RUN rm /var/lib/apt/lists/* -vf \
    # Base dependencies
    && apt-get -y update \
    && apt-get -y dist-upgrade \
    && apt-get -y --force-yes install --fix-missing $APT_LIST

# gh cli
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg  \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt update \
    && apt install gh

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# installing nvim
RUN mkdir -p /opt/nvim/ && cd /opt/nvim \
    && curl -LO https://github.com/neovim/neovim/releases/download/v0.5.0/nvim.appimage \
    && chmod +x nvim.appimage \
    && ./nvim.appimage --appimage-extract \
    && ln -sf /opt/nvim/squashfs-root/usr/bin/nvim /usr/bin/nvim

# Add Tini
# https://stackoverflow.com/questions/49162358/docker-init-zombies-why-does-it-matter
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

# Create user and config
RUN useradd -m -u 1000 -s /bin/zsh $UNAME -G sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN sudo chown -R $UNAME:$UNAME /home/$UNAME
USER $UNAME
WORKDIR /home/$UNAME

# oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN sh -c 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'

# dotfiles
ENV DOTFILES="$HOME/.dotfiles"
RUN git clone --recurse-submodules --depth 1 https://github.com/mmngreco/dotfiles $DOTFILES && $DOTFILES/install
RUN sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
RUN nvim --headless +PlugInstall +qall

# source bashrc
# RUN echo "source /root/.bashrc" >> /etc/profile

COPY ./entrypoint.sh /
ENTRYPOINT [ "/usr/bin/tini", "--", "/entrypoint.sh" ]

CMD [ "/bin/zsh", " -i" ]
