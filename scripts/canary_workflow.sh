#!/bin/sh

FORCE_BUILD=false

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
    -fb|--FORCE_BUILD)
      FORCE_BUILD=true
      shift # past argument
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
WF="${WF:-dper.workflows.ads.train_eval_workflow}"
MODE=${MODE:-opt}
TITLE=${TITLE:-"${PREFIX:+${PREFIX}, }""${DIFF} ${MODE}""${SUFFIX:+, ${SUFFIX}}"}

echo "FBC            = ${FBC}"
echo "PREFIX         = ${PREFIX}"
echo "SUFFIX         = ${SUFFIX}"
echo "DIFF           = ${DIFF}"
echo "TITLE          = ${TITLE}"
echo "WORKFLOW       = ${WF}"
echo "MODE           = ${MODE}"
echo "FORCE_BUILD    = ${FORCE_BUILD}"
if [[ -n $@ ]]; then
  echo $# POSITIONAL ARGUMENTS: $@
fi

if [[ $MODE == "default" ]]; then
  CMD="flow-cli canary $WF --name \"$TITLE\""
else
  CMD="flow-cli canary --mode $MODE $WF --name \"$TITLE\""
fi

if $FORCE_BUILD; then
  CMD="FLOW_FORCE_BUILD=1 ""$CMD"
fi

echo "$CMD"
eval "$CMD"

cd $dir
