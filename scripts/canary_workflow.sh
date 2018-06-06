#!/bin/sh

POSITIONAL=()
while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
    -p|--prefix)
      PREFIX="$2"
      shift # past argument
      shift # past value
      ;;
    -s|--suffix)
      SUFFIX="$2"
      shift # past argument
      shift # past value
      ;;
    -f|--FBC)
      FBC="$2"
      shift # past argument
      shift # past value
      ;;
    -w|--WF)
      WF="$2"
      shift # past argument
      shift # past value
      ;;
    -t|--TITLE)
      TITLE="$2"
      shift # past argument
      shift # past value
      ;;
    -m|--MODE)
      MODE="$2"
      shift # past argument
      shift # past value
      ;;
    *)    # unknown option
      POSITIONAL+=("$1") # save it in an array for later
      shift # past argument
      ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

dir=$(pwd)
FBC=${FBC:-~/fbcode}
cd $FBC
DIFF="$(hg log -r . --template '{xg_sl_normal}' | tr -s ' ')"
TITLE=${TITLE:-"${PREFIX:+${PREFIX}, }""${DIFF}""${SUFFIX:+, ${SUFFIX}}"}
WF="${WF:-dper.workflows.ads.train_eval_workflow}"
MODE=${MODE:-opt}

echo "FBC            = ${FBC}"
echo "PREFIX         = ${PREFIX}"
echo "SUFFIX         = ${SUFFIX}"
echo "DIFF           = ${DIFF}"
echo "TITLE          = ${TITLE}"
echo "WORKFLOW       = ${WF}"
echo "MODE           = ${MODE}"
if [[ -n $@ ]]; then
  echo $# POSITIONAL ARGUMENTS: $@
fi


CMD="flow-cli canary\
  --mode $MODE $WF\
  --name \"$TITLE\""
echo "$CMD"
eval "$CMD"

cd $dir
