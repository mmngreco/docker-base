ARG IMAGE_BASE=python:3.6
FROM $IMAGE_BASE

ENV DEBIAN_FRONTEND=noninteractive
ENV IS_DOCKER=1

ENV USERNAME=docker
ENV HOME=/home/$USERNAME
ARG UID=1000
ARG GID=1000

SHELL [ "/bin/bash", "-c" ]

COPY etc/odbcinst.ini /etc/odbcinst.ini

# DB CONFIGURATION
RUN mkdir -p ~/.ssh && chmod 0700 ~/.ssh

# git secret
RUN rm -rvf /var/lib/apt/lists/*
RUN apt update \
    && apt install -y gnupg2 wget \
    && echo 'deb https://gitsecret.jfrog.io/artifactory/git-secret-deb git-secret main' >> /etc/apt/sources.list \
    && wget -qO - 'https://gitsecret.jfrog.io/artifactory/api/gpg/key/public' | apt-key add - \
    && apt update -y \
    && apt install -y git-secret

ARG APT_LIST
RUN apt-get -y dist-upgrade && apt-get -y --force-yes install --fix-missing $APT_LIST


# Add Tini
# https://stackoverflow.com/questions/49162358/docker-init-zombies-why-does-it-matter
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini


# Create user and config
RUN groupadd -f -g $GID $USERNAME && useradd -ms /bin/zsh --uid $UID --gid $GID ${USERNAME} && usermod -aG sudo ${USERNAME}
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME
USER $USERNAME
WORKDIR $HOME

# personal setup
ENV DOTFILES="$HOME/.dotfiles"
RUN git clone --recurse-submodules https://github.com/mmngreco/dotfiles $DOTFILES && $DOTFILES/software/all && $DOTFILES/install

# clean up
RUN sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./entrypoint.sh /
ENTRYPOINT [ "/usr/bin/tini", "--", "/entrypoint.sh" ]

CMD [ "/bin/zsh", " -i" ]
