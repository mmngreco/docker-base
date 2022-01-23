#!/usr/bin/env bash
dotfiles pull
reload
clear

[ ! -f "/usr/bin/python" ] && sudo ln /usr/bin/python3 /usr/bin/python

case $1 in
    bash)
        bash -i
        ;;
    zsh)
        zsh -i
        ;;
    install)
        pip install . -r requirements.txt -r requirements-test.txt
        ;;
    build)
        python setup.py bdist_wheel sdist
        ;;
    test)
        pip install . -r requirements.txt -r requirements-test.txt
        pytest --ff -v
        ;;
    help)
        echo "Options:"
        echo "    install"
        echo "    test"
        echo "    bash"
        echo "    zsh"
        ;;
    *)
        zsh -i -c "$@"
        ;;
esac

