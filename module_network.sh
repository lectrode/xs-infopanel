#!/bin/bash

###########
#settings #
###########

getpublicip="yes" #enables/disables getting/caching/displaying public ip address

#only used if above is "yes":
cachefile="${HOME}/.cache/xs-infopanel/nwk.dat" #recommended to be stored in tmpfs
cachefile_persist="${HOME}/.cache_keep/xs-infopanel/nwk.dat" #somewhere persistent across reboots
notifyonpub="yes" #enable/disable notification on public ip change
checkpubevery="24" #time in hours to check public ip address

###########
#functions#
###########

msg(){ notify-send -i dialog-warning "new ext ip" "$@" ; }

###########
#  main   #
###########


#begin public ip section
if [[ "$getpublicip" = "yes" ]]; then


typeset -A lastlocal
typeset -A currlocal

#read cache file
[[ ! -f "$cachefile" ]] && [[ -f "$cachefile_persist" ]] && mkdir -p "$(dirname "$cachefile")" >/dev/null && cp -f "$cachefile_persist" "$cachefile" >/dev/null
if [[ -f "$cachefile" ]]; then
  while read -r l; do
    case "$(echo "$l"|cut -d' ' -f1)" in
      pubip) pubip_last="$(echo "$l"|cut -d' ' -f2-)" ;;
      lastget) pubipdate_last="$(echo "$l"|cut -d' ' -f2-)" ;;
      *) lastlocal["$(echo "$l"|cut -d' ' -f1)"]="$(echo "$l"|cut -d' ' -f2-)"  ;;
    esac
  done <<< "$(cat "$cachefile"|grep -Eiv '[^a-z0-9\.\:\/ \-]'|grep -E '[a-z0-9]')" #sanitize input
fi

#get current local ip(s)
while read -r l; do
  currlocal["$(echo "$l"|cut -d' ' -f1)"]="$(echo "$l"|cut -d' ' -f3-)"
done <<< "$(ip --brief addr|grep -Eiv '[^a-z0-9\.\:\/ ]'|grep -E '[a-z0-9]'|grep -Ev '(^lo | DOWN )'|sed -r 's/ +/ /g')"

#need new public ip if *all* local ip addresses changed
#(checking all prevents needless re-checking of external ip if i.e. switching from wired to wireless)
needcheck=1; for a in "${!currlocal[@]}"; do
  if [[ ! "${lastlocal["$a"]}" = "" ]] && [[ "${lastlocal["$a"]}" = "${currlocal["$a"]}" ]]; then
    needcheck=0; break; fi
done

#need new public ip if public ip not yet defined, or if timer is up
[[ "$needcheck" = "0" ]] && if [[ "$pubip_last" = "" ]]; then needcheck=1
elif [[ "$(date +'%F %H:%M')" > "$(date -d "$(date -d "$pubipdate_last")+$checkpubevery hours" +'%F %H:%M')" ]]
  then needcheck=1; fi

#get new public ip/timestamp if needed
if [[ "$needcheck" = "1" ]]; then
  pubip="$(curl -s 'http://myexternalip.com/raw'|grep -Eiv '[^a-z0-9\.\:\/]')"
  if [[ "$pubip" = "" ]]; then
    msg "failed to get external ip"
  else pubipdate="$(date +'%F %H:%M')"
    msg "new external ip: $pubip"
  fi
fi

#export new info if needed
if [[ ! "$pubip" = "" ]] || [[ ! "${!currlocal[@]}" = "${!lastlocal[@]}" ]] || [[ ! "${currlocal[@]}" = "${lastlocal[@]}" ]]
  then mkdir -p "$(dirname "$cachefile")"
  echo "pubip $pubip" > "$cachefile"
  echo "lastget $pubipdate" >> "$cachefile"
  for a in "${!currlocal[@]}"; do
    echo "$a ${currlocal["$a"]}" >> "$cachefile"
  done
  mkdir -p "$(dirname "$cachefile_persist")"
  cp -f "$cachefile" "$cachefile_persist"
fi

#display public ip
[[ "$pubip" = "" ]] && pubip="$pubip_last"
[[ "$pubipdate" = "" ]] && pubipdate="$pubipdate_last"
[[ "$pubip" = "" ]] || echo "\$template0Public IP: \${color}$pubip \${color1}(Updated: \${color}$pubipdate\${color1})"


#end public ip section
fi


#display local adapter info
for p in $(ls /sys/class/net); do
  [[ "$p" = "lo" ]] && continue
  conn=d; [[ -d "/sys/class/net/$p/wireless" ]] && conn=b
  echo "\${if_up $p}\$template0\${stippled_hr}"
  echo "\$template0\${font ConkySymbols:size=16}$conn\${font} $p \${alignr}\${color}\${addr $p}"
  if [[ "$conn" = "b" ]]; then
    echo "\$template0SSID : \${color}\${wireless_essid $p} \${color1}\${alignr} \${color}\${wireless_link_qual_perc $p}% \${wireless_link_bar 7,100 $p}"
  fi
  echo "\$template0Speed: \${color}\${downspeed $p}\${color1}▼\${color} \${upspeed $p}\${color1}▲\${color}\${alignr}\${color1}Tot: \${color}\${totaldown $p}\${color1}▼\${color} \${totalup $p}\${color1}▲\${color0}\$endif"
done

exit 0


