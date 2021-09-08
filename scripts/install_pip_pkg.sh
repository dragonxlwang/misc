#!/bin/sh

# pip
# alias pip=pip3
alias pip=/usr/bin/pip3
pip install --user --upgrade pip
pip install --user "ipython[all]" --upgrade ## --force-reinstall
# sudo -H pip install -U nltk
## python -m nltk.downloader all
pip install --user  jupyter
pip install --user flake8
pip install --user pep8
pip install --user autopep8
pip install --user yapf
pip install --user jedi
pip install --user psutil
pip install --user pysqlite
pip install --user numpy
pip install --user scipy
pip install --user matplotlib
pip install --user numba
pip install --user pillow
pip install --user pygame

# pip install -U $(curl -s
#   https://api.github.com/repos/matplotlib/basemap/releases/latest |
#   grep zipball_url | awk '{print $2}' | cut -d \" -f2)
pip install --user git+https://github.com/matplotlib/basemap.git
