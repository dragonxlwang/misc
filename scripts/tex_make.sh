#!/bin/bash

# check if .latexrc exists

if [[ ! -a .latexmkrc ]]; then
  echo "\$pdf_previewer = \"open -a /Applications/Skim.app\";" >> .latexmkrc
  echo "\$clean_ext = \"paux lox pdfsync out\";" >> .latexmkrc
  echo "@default_files = ('main.tex');" >> .latexmkrc
fi

if [[ $1 == "make" ]]; then
  latexmk -pdf
elif [[ $1 == 'clean' ]]; then
  latexmk -C
fi

