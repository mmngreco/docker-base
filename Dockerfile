FROM debian:buster-slim
ENV DEBIAN_FRONTEND=noninteractive

ARG SSH_PRIVATE_KEY
ARG SSH_PUBLIC_KEY
ARG APT_LIST
ARG CONFIG_INI
ARG PY_VER

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# DB CONFIGURATION
RUN mkdir -p /ETS/git \
    && mkdir -p ~/.ssh \
    && chmod 0700 ~/.ssh \
    && mkdir -p /ETS/configs \
    && mkdir -p /ETS/venvs

RUN rm /var/lib/apt/lists/* -vf \
    # Base dependencies
    && apt-get -y update \
    && apt-get -y dist-upgrade \
    && apt-get -y --force-yes install \
        --fix-missing \
        apt-utils \
        build-essential \
        bzip2 \
        ca-certificates \
        curl \
        freetds-bin \
        freetds-dev \
        git \
        gnupg \
        libbz2-dev \
        libfontconfig \
        liblzma-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        libffi-dev \
        make \
        net-tools \
        openssh-client \
        readline-common \
        supervisor \
        tdsodbc \
        unixodbc \
        unixodbc-dev \
        vim \
        wget \
        xz-utils \
        zlib1g-dev

COPY bashrc /root/.bashrc
COPY etc/odbcinst.ini /etc/odbcinst.ini

RUN echo =========================================================== \
    # Pyenv Installation
    && echo pyenv installation \
    && curl https://pyenv.run | bash \
    && . ~/.bashrc \
    && env PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install -f $PY_VER \
    && env PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install -f 3.5.10 \
    && env PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install -f 3.6.13 \
    && env PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install -f 3.7.10 \
    && env PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install -f 3.8.8 \
    && env PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install -f 3.9.2 \
    && pyenv rehash \
    && pyenv local 3.5.10 3.6.13 3.7.10 3.8.8 3.9.2 \
    && pip install pip==18.* --upgrade \
    && echo "pyenv global $PY_VER\n\n" >> ~/.bashrc


ENV SSH_PRIVATE_KEY=$SSH_PRIVATE_KEY
ENV SSH_PUBLIC_KEY=$SSH_PUBLIC_KEY
RUN echo =========================================================== \
    && echo add identity \
    && echo SSH SETUP \
    # https://stackoverflow.com/a/37779390/3124367?stw=2
    && $(which ssh-agent) \
    # Authorize SSH Host
    && echo =========================================================== \
    && echo AUTHORIZE SSH HOST \
    && ssh-keyscan -H etsgit1.ets.es >> ~/.ssh/known_hosts \
    && ssh-keyscan -H etsgit1 >> ~/.ssh/known_hosts \
    # Add identity
    && echo =========================================================== \
    && echo ADD IDENTITY \
    && eval $(ssh-agent) \
    && ssh-add \
    # Test ssh connection
    && echo =========================================================== \
    && echo TEST SSH CONNECTION \
    && ssh -v -T git@etsgit1.ets.es

RUN apt-get -y --force-yes install $APT_LIST

# Cleanup
RUN echo =========================================================== \
    && echo cleanup \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Clean SSH KEYS
ENV SSH_PRIVATE_KEY=
ENV SSH_PUBLIC_KEY=
RUN rm ~/.ssh/id_rsa*

# Add Tini
# https://stackoverflow.com/questions/49162358/docker-init-zombies-why-does-it-matter
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT [ "/usr/bin/tini", "--" ]

WORKDIR /ETS/git
CMD ["/bin/bash"]
