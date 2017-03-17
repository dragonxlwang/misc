#!/usr/bin/env zsh

curpwd=$(pwd)
cd ${HOME}
/bin/rm -rf .oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
cd ~/.oh-my-zsh/custom/plugins
git clone https://github.com/zsh-users/zsh-completions.git
git clone https://github.com/zsh-users/zsh-autosuggestions.git
~/misc/scripts/setup_symlinks.sh linux --no-confirm

cd $curpwd

