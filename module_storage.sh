#!/bin/bash

for d in $(mount|grep -oE '/dev/[0-9a-z]+ on '|sort -u|cut -d' ' -f1); do
  p="$(mount|grep -oE "$d on [0-9a-zA-Z\/]+"|awk '{print length, $0}'|sort|head -n1|cut -d' ' -f4-)"
  dsp="            $p"; dsp="$(echo ${dsp: -12:12}|xargs)"
  echo "\$template0$(echo "$dsp            "|cut -c1-12): \${color}\${fs_used $p}/\${fs_size $p} \${alignr}\${fs_used_perc $p}% \${if_match 750 < \${fs_used_perc $p}0}\${color2}\$endif\${if_match 900 < \${fs_used_perc $p}0}\${color3}\$endif\${fs_bar 7,100 $p}"
done

exit 0
