ARG IMAGE_BASE=python:3.6
FROM $IMAGE_BASE

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root
ENV IS_DOCKER=1
SHELL [ "/bin/bash", "-c" ]

COPY etc/odbcinst.ini /etc/odbcinst.ini

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# DB CONFIGURATION
RUN mkdir -p ~/.ssh && chmod 0700 ~/.ssh

ARG APT_LIST
RUN rm /var/lib/apt/lists/* -vf \
    # Base dependencies
    && apt-get -y update \
    && apt-get -y dist-upgrade \
    && apt-get -y --force-yes install --fix-missing $APT_LIST

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add Tini
# https://stackoverflow.com/questions/49162358/docker-init-zombies-why-does-it-matter
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENV DOTFILES="$HOME/.dotfiles"
RUN git clone --recurse-submodules --depth 1 https://github.com/mmngreco/dotfiles $DOTFILES \
    && cd $DOTFILES && ./install

RUN curl -LO https://github.com/neovim/neovim/releases/download/v0.5.0/nvim.appimage \
    && chmod +x nvim.appimage \
    && mv nvim.appimage /usr/local/bin/

RUN echo "source /root/.bashrc" >> /etc/profile
COPY ./entrypoint.sh /
ENTRYPOINT [ "/usr/bin/tini", "--", "/entrypoint.sh" ]
CMD [ "/bin/bash", " -i" ]
