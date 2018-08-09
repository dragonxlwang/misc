#!/bin/sh

if [[ ! -f ${HOME}/fbcode/buck-out/gen/everstore/clowder/clowder/clowder ]]; then
  pushd . > /dev/null 2>&1
  cd ${HOME}/fbcode
  buck build @mode/opt //everstore/clowder:clowder
  popd > /dev/null 2>&1
fi

${HOME}/fbcode/buck-out/gen/everstore/clowder/clowder/clowder urlgen $*
