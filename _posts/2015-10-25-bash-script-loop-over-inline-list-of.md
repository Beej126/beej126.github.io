---
title: Bash script – loop over inline list of files
date: 2015-10-25
author: Beej
tags:
  - CommandLine
---
<pre class="prettyprint">#!/bin/bash

#echo $BASH_VERSION

# read args:
# -r = disable backslash escaping
# -d '' = read the whole here-doc as one big input vs stopping stopping at the first new line as the default delimiter
# -a = put the results into an array
#the minus in "<<-" provides for indenting the here-doc lines, but with TABS ONLY
#bash4 is way easier but wanted to be portable: readarray -t arr <<-"EOT"
IFS=$'n' read -r -d '' -a arr <<-'EOF'
    /file/path/1
    /file/path/2
    /file/path/3
EOF

#echo ${#arr[*]}

# https://stackoverflow.com/questions/9084257/bash-array-with-spaces-in-elements
# disable default space delimiter
IFS=""
for filePath in ${arr[*]}
do
  stat "${filePath}"
done

unset IFS</pre>