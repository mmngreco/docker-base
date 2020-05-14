FROM osixia/ubuntu-light-baseimage:0.2.1

ARG SSH_PRIVATE_KEY
ARG SSH_PUBLIC_KEY
ARG APT_LIST
ARG CONFIG_INI

ENV SSH_PRIVATE_KEY=$SSH_PRIVATE_KEY
ENV SSH_PUBLIC_KEY=$SSH_PUBLIC_KEY
ENV PYMO_USE_CACHE=0
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

ENV PYENV_ROOT=/root/.pyenv
ENV PATH="$PYENV_ROOT/bin:$PATH"
RUN echo =========================================================== \
    # Pyenv Installation
    && echo pyenv installation \
    && curl https://pyenv.run | bash \
    && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc \
    && echo 'if command -v pyenv 1>/dev/null 2>&1; then' >> ~/.bashrc \
    && echo '    eval "$(pyenv init -)"' >> ~/.bashrc \
    && echo 'fi' >> ~/.bashrc \
    && . ~/.bashrc \
    && env PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install -f 3.6.10 \
    && echo "pyenv global 3.6.10" >> ~/.bashrc \
    # freetds driver
    && echo =========================================================== \
    && echo freetds drivers \
    && echo "[FreeTDS]" > /etc/odbcinst.ini \
    && echo "Description = TDS driver (Sybase/MS SQL)" >> /etc/odbcinst.ini \
    && echo "Driver = /usr/lib/x86_64-linux-gnu/odbc/libtdsodbc.so" >> /etc/odbcinst.ini \
    && echo "Setup = /usr/lib/x86_64-linux-gnu/odbc/libtdsS.so" >> /etc/odbcinst.ini

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
ENV PATH="/root/.pyenv/shims/:$PATH"

WORKDIR /ETS/git

ENTRYPOINT /bin/bash
CMD ["/bin/bash"]
