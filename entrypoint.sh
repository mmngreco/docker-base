#!/usr/bin/env bash
source ~/.bashrc

case $1 in
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
        zsh -i
        ;;
esac

