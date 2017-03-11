#!/bin/bash
for file in tests/*.rtn; do
  echo "\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#"
  echo "$file"
  echo "\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#"
  ./retina "$file"
  echo "\n\n"
done
