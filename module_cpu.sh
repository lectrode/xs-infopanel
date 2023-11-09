#!/bin/bash

p=0
while [ "$p" -lt "$(grep -c 'model name' /proc/cpuinfo)" ]; do
  echo "\${color1}\${goto 30}Core $p : \${color}\${freq_g $p}GHz \${alignr}\${cpu cpu$p}% \${if_match 850 < \${cpu cpu$p}0}\${color2}\$endif\${if_match 900 < \${cpu cpu$p}0}\${color3}\$endif\${cpubar cpu$p 4,100}"
  p=$(($p + 1))
done
exit 0
