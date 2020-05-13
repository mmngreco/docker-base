export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

if [ ! -z "$SSH_PRIVATE_KEY" ]
then
    # mkdir -p ~/.ssh
    echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
fi

if [ ! -z "$SSH_PUBLIC_KEY" ]
then
    # mkdir -p ~/.ssh
    echo "$SSH_PUBLIC_KEY" > ~/.ssh/id_rsa.pub
    chmod 600 ~/.ssh/id_rsa.pub
fi

if [ ! -z "$CONFIG_INI" ]
then
    # mkdir -p /ETS/configs/
    echo "$CONFIG_INI" > /ETS/configs/config.ini
fi
