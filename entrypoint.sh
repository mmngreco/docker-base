#!/usr/bin/env bash
source ~/.bashrc

case $1 in
    install)
        pip install . -r requirements.txt -r requirements-test.txt
        ;;
    tmux)
        tmux new /bin/bash -i
        ;;
    build)
        python setup.py bdist_wheel sdist
        ;;
    test)
        pip install . -r requirements.txt -r requirements-test.txt
        pytest --ff -v
        ;;
    bash)
        bash --rcfile $DOTFILES/shell/bashrc
        ;;
    zsh)
        zsh
        ;;
    help)
        echo "Options:"
        echo "    install"
        echo "    test"
        echo "    bash"
        echo "    zsh"
        ;;
    *)
        bash -i
        ;;
esac

