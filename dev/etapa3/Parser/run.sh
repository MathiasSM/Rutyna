#!/bin/bash
i=1
for file in tests/*.rtn; do
  echo "####################################################################################   $file"
  echo ""
  ./retina "$file"
  echo;
  let i=i+1
  if [ $# -gt 0 ] && [ $i -gt $1 ] ; then
    exit
  fi
done
