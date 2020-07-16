#!/bin/bash

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
    -e|--ENTITLEMENT)
      ENTITLEMENT="$2"
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
cd "$FBC" || exit
hg_template="{separate('  ', sl_userdefined_prefix, shortest(node, sl_hash_minlen),\
 date(date), sl_user, sl_diff, sl_tasks, sl_books, sl_branch,\
 sl_userdefined_suffix)}"
DIFF="$(hg log -r . --template "${hg_template}" | tr -s ' ')"
WF="${WF:-dper.workflows.ads.train_eval_workflow}"
MODE=${MODE:-opt}
TITLE=${TITLE:-"${PREFIX:+${PREFIX}, }""${DIFF} ${MODE}""${SUFFIX:+, ${SUFFIX}}"}
ENTITLEMENT=${ENTITLEMENT:-ads_ftw}

echo "FBC            = ${FBC}"
echo "PREFIX         = ${PREFIX}"
echo "SUFFIX         = ${SUFFIX}"
echo "DIFF           = ${DIFF}"
echo "TITLE          = ${TITLE}"
echo "WORKFLOW       = ${WF}"
echo "MODE           = ${MODE}"
echo "FORCE_BUILD    = ${FORCE_BUILD}"
echo "ENTITLEMENT    = ${ENTITLEMENT}"
if [[ -n "$*" ]]; then
  echo $# POSITIONAL ARGUMENTS: "$@"
fi

CMD=()
$FORCE_BUILD && CMD+=("FLOW_FORCE_BUILD=1")
CMD+=("flow-cli" "canary")
CMD+=("--entitlement" "$ENTITLEMENT")
[[ $MODE != "default" ]] && CMD+=("--mode" "$MODE")
CMD+=("$WF")
CMD+=("--name" "\"$TITLE\"")

echo "${CMD[@]}"
eval "${CMD[@]}"

cd "$dir" || exit
