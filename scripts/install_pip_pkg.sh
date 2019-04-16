#!/bin/sh

# pip
alias pip=pip3
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
pip install -U pysqlite
pip install -U numpy
pip install -U scipy
pip install -U matplotlib
pip install -U numba
pip install -U pillow
pip install -U pygame

# pip install -U $(curl -s
#   https://api.github.com/repos/matplotlib/basemap/releases/latest |
#   grep zipball_url | awk '{print $2}' | cut -d \" -f2)
pip install -U git+https://github.com/matplotlib/basemap.git


