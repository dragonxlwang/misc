#!/bin/sh

# pip
pip install --upgrade pip
pip install "ipython[all]" --upgrade ## --force-reinstall
sudo -H pip install -U nltk
## python -m nltk.downloader all
pip install -U jupyter
pip install -U flake8
pip install -U pep8
pip install -U autopep8
pip install -U yapf
pip install -U jedi
pip install -U psutil
