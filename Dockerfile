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
    && mkdir -p /ETS/configs \
    && mkdir -p /ETS/venvs \
    && echo "$CONFIG_INI" > /ETS/configs/config.ini

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
        zlib1g-dev \
        $APT_LIST \
    # Pyenv Installation
    && echo =========================================================== \
    && echo pyenv installation \
    && curl https://pyenv.run | bash \
    && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc \
    && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc \
    && echo 'if command -v pyenv 1>/dev/null 2>&1; then' >> ~/.bashrc \
    && echo '    eval "$(pyenv init -)"' >> ~/.bashrc \
    && echo 'fi' >> ~/.bashrc \
    && . ~/.bashrc \
    && pyenv install -f 3.6.10 \
    && echo "pyenv global 3.6.10" >> ~/.bashrc \
    # Cleanup
    && echo =========================================================== \
    && echo cleanup \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    # freetds driver
    && echo =========================================================== \
    && echo freetds drivers \
    && echo "[FreeTDS]" > /etc/odbcinst.ini \
    && echo "Description = TDS driver (Sybase/MS SQL)" >> /etc/odbcinst.ini \
    && echo "Driver = /usr/lib/x86_64-linux-gnu/odbc/libtdsodbc.so" >> /etc/odbcinst.ini \
    && echo "Setup = /usr/lib/x86_64-linux-gnu/odbc/libtdsS.so" >> /etc/odbcinst.ini

RUN echo add identity \
    && echo =========================================================== \
    && echo SSH SETUP \
    # https://stackoverflow.com/a/37779390/3124367?stw=2
    && $(which ssh-agent) \
    && mkdir -p /root/.ssh \
    && chmod 0700 /root/.ssh \
    # Authorize SSH Host
    && echo =========================================================== \
    && echo AUTHORIZE SSH HOST \
    && ssh-keyscan -H etsgit1.ets.es >> /root/.ssh/known_hosts \
    && ssh-keyscan -H etsgit1 >> /root/.ssh/known_hosts \
    # Create key files
    && echo =========================================================== \
    && echo CREATE KEY FILES \
    && echo SSH PRIVATE KEY \
    && echo "$SSH_PRIVATE_KEY" | tr -d '\r' \
    && echo SSH PUBLIC KEY \
    && echo "$SSH_PUBLIC_KEY" | tr -d '\r' \
    && echo TEMPORAL STORING SSH KEYS \
    && echo "$SSH_PRIVATE_KEY" | tr -d '\r' > ~/.ssh/id_rsa \
    && echo "$SSH_PUBLIC_KEY" | tr -d '\r' > ~/.ssh/id_rsa.pub \
    && chmod 600 /root/.ssh/id_rsa \
    && chmod 600 /root/.ssh/id_rsa.pub \
    # Add identity
    && echo =========================================================== \
    && echo ADD IDENTITY \
    && eval $(ssh-agent) \
    && ssh-add \
    # Test ssh connection
    && echo =========================================================== \
    && echo TEST SSH CONNECTION \
    && ssh -v -T git@etsgit1.ets.es

RUN echo "echo \"\$SSH_PRIVATE_KEY\" | tr -d \'\r\' > ~/.ssh/id_rsa" >> /root/.bashrc \
    && echo "echo \"\$SSH_PUBLIC_KEY\" | tr -d \'\r\' > ~/.ssh/id_rsa.pub" >> /root/.bashrc \
    && echo "chmod 600 /root/.ssh/id_rsa" >> /root/.bashrc \
    && echo "chmod 600 /root/.ssh/id_rsa.pub" >> /root/.bashrc \
    && echo "[ ! -z \"\$CONFIG_INI\" ] && echo \"\$CONFIG_INI\" > /ETS/configs/config.ini" >> /root/.bashrc

# Clean SSH KEYS
ENV SSH_PRIVATE_KEY=
ENV SSH_PUBLIC_KEY=
RUN rm ~/.ssh/id_rsa*

WORKDIR /ETS/git


CMD ["/bin/bash"]
