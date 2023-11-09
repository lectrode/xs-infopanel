#!/bin/bash

for p in $(ls /sys/class/net); do
  [[ "$p" = "lo" ]] && continue
  conn=d; [[ -d "/sys/class/net/$p/wireless" ]] && conn=b
  #echo "\${if_up $p}\${color1}\${goto 30}\${stippled_hr}\${color}"
  echo "\${if_up $p}\${color1}\${goto 30}\${font ConkySymbols:size=16}$conn\${font} $p \${alignr}\${color}\${addr $p}"
  if [[ "$conn" = "b" ]]; then
    echo "\${color1}\${goto 30}SSID : \${color}\${wireless_essid $p} \${color1}\${alignr} \${color}\${wireless_link_qual_perc $p}% \${wireless_link_bar 7,100 $p}"
  fi
  echo "\${color1}\${goto 30}Speed: \${color}\${downspeed $p}\${color1}▼\${color} \${upspeed $p}\${color1}▲\${color}\${alignr}\${color1}Tot: \${color}\${totaldown $p}\${color1}▼\${color} \${totalup $p}\${color1}▲\${color0}\$endif"
done

exit 0



