#!/bin/sh

# basic alias
export GREP_OPTIONS='--color=auto'
export PS1="\[\033[1m\]\u\[\033[1;35m\]@\[\033[1;31m\]\h\[\033[1;37m\]: \[\033[1;36m\]\W \[\033[1;37m\]\$ \[\033[0m\]"
alias grep='grep -n'
alias ls='ls --color'
alias ll='ls -al --color -X';
alias cf='ls -f | wc -l';
alias mkdir='mkdir -p';
alias easy_install='easy_install --prefix=~/local';
alias pip='~/local/bin/pip install --install-option="--prefix=~/local"';
alias cp='cp -rf';
LS_COLORS='di=1:fi=36:ln=95:pi=5:so=5:bd=5:cd=5:or=31:mi=31:ex=95:*.rpm=90'
export LS_COLORS
#export LSCOLORS=fxfxaxdxcxegedabagacad
export PYTHONPATH=$PYTHONPATH:/home/xwang95/local/lib/python2.6/site-packages:/home/xwang95/local/lib64/python2.6/site-packages
alias pip='/home/xwang95/local/bin/pip'
alias pip_install='/home/xwang95/local/bin/pip install --install-option="--prefix=$HOME/local"'
alias easy_install_package='easy_install --prefix=$HOME/local'
alias rm='mv --verbose -f --backup=numbered --target-directory ~/.trash/'
alias empty_trash='/bin/rm -rf --verbose  ~/.trash/*'
alias killall='killall -u xwang95' #kill all
alias dir_size='for f in $("ls"); do du -lsh $f; done;';
alias cls='printf "\033c"';
# svn
SVN_SRC='https://subversion.cs.illinois.edu/svn/TIMan/xwang95-self/src/'
alias svn_checkout='svn checkout $SVN_SRC --username xwang95'
alias svn_update='svn update --username xwang95'
function svn_unversioned {
    svn st| grep ^?| awk '{print $2}'
}
function svn_add {
    svn add `svn_unversioned`
}
alias svn_revert='svn revert --recursive .'
alias svn_commit='svn commit -m "add new files"'

# hadoop
alias hkinit='kinit wangxl@Y.CORP.YAHOO.COM'
alias hls='hadoop fs -ls'
alias hcat='hadoop fs -cat'
alias hcopyFromLocal='hadoop fs -copyFromLocal' 
alias hmkdir='hadoop fs -mkdir'
alias hrmdir='hadoop fs -rm -r'
alias hcopyFromLocal='hadoop fs -copyFromLocal'
alias hcopyToLocal='hadoop fs -copyToLocal'
alias hchmod='hadoop fs -chmod'
alias hmv='hadoop fs -mv'
function hjoblst {
    num=3;
    if [ $# -ne 0 ]; then num=$1; fi;
    echo -e "\033[1;36m$(hadoop job -list all | \grep wangxl | sort -t $'\t' -n -k 3,3 | tail -n $num | awk '{$1=$1}1' OFS='\n' ORS='\n\n')\03    3[0m"
}
export hqueueSearchGeneral='search_general'
export hqueueFastLane='search_fast_lane'
export NB=hfs://nitroblue-nn1.blue.ygrid.yahoo.com:8020
function hview { 
    hcat $1/* | zcat | less
}
function hzcat {
    hcat $1/* | zcat
}
function hvim {
    hcat $1/* | zcat | vim -
}
function hwc {
    hcat $1/* | zcat | wc
}
function hadoop_streaming {
    hadoop jar $HADOOP_PREFIX/share/hadoop/tools/lib/hadoop-streaming.jar \
    -Dmapred.job.queue.name=$hqueueSearchGeneral \
    -mapper $1 \
    -reducer $2 \
    -input $3 \
    -output $4
    -file $1
    -file $2
}
function hmergeToLocal {
    hadoop fs -cat $1/* | zcat > $1
}
alias pig_run="pig -Dmapred.job.queue.name=search_fast_lane -Dmapred.map.tasks.speculative.execution=true -Dmapred.reduce.tasks.speculative.ex    ecution=true"

# profile_wangxl
source ${HOME}/.profile_wangxl
