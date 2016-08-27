#!/bin/bash

# check if .latexrc exists

if [[ ! -a .latexmkrc ]]; then
  echo "\$pdf_previewer = \"open -a /Applications/Skim.app\";" >> .latexmkrc
  echo "@default_files = ('main.tex');" >> .latexmkrc
  echo "\$pdflatex = 'pdflatex -pdf -verbose -file-line-error -synctex=1 -interaction=nonstopmode %O %S';" >> .latexmkrc
  echo "\$clean_ext = \"paux lox pdfsync out synctex.gz\";" >> .latexmkrc
fi

if [[ $1 == "make" ]]; then
  latexmk -pdf
elif [[ $1 == "preview" ]]; then
  latexmk -pdf -pvc
elif [[ $1 == 'clean' ]]; then
  latexmk -C
fi

