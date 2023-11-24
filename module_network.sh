#!/bin/bash

###########
#settings #
###########

getpublicip="yes" #enables/disables getting/caching/displaying public ip address

#only used if above is "yes":
cachefile="${HOME}/.cache/xs-infopanel/nwk.dat" #recommended to be stored in tmpfs
cachefile_persist="${HOME}/.cache_keep/xs-infopanel/nwk.dat" #somewhere persistent across reboots
notifyonpub="yes" #enable/disable notification on public ip change
checkpubevery="24" #maximum time in hours between public ip address checks

###########
#functions#
###########

msg_red(){ notify-send -t 0 -i dialog-error "xs-infopanel" "$@" ; }
msg_yel(){ notify-send -t 0 -i dialog-warning "xs-infopanel" "$@" ; }
msg_grn(){ notify-send -i emblem-default "xs-infopanel" "$@"; }

###########
#  main   #
###########


#begin public ip section
while [[ "$getpublicip" = "yes" ]]; do


typeset -A lastlocal
typeset -A currlocal

#read cache file
[[ ! -f "$cachefile" ]] && [[ -f "$cachefile_persist" ]] && mkdir -p "$(dirname "$cachefile")" >/dev/null && cp -f "$cachefile_persist" "$cachefile" >/dev/null
if [[ -f "$cachefile" ]]; then
  while read -r l; do
    case "$(echo "$l"|cut -d' ' -f1)" in
      "") continue ;;
      pubip) pubip_last="$(echo "$l"|cut -d' ' -f2-)" ;;
      lastget) pubipdate_last="$(echo "$l"|cut -d' ' -f2-)" ;;
      *) lastlocal["$(echo "$l"|cut -d' ' -f1)"]="$(echo "$l"|cut -d' ' -f2-)"  ;;
    esac
  done <<< "$(cat "$cachefile"|grep -Eiv '[^a-z0-9\.\:\/ \-]'|grep -E '[a-z0-9]')" #sanitize input
fi
[[ "$pubip_last" = "pubip" ]] && unset pubip_last
date -d "$pubipdate_last" >/dev/null 2>&1 || unset pubipdate_last

#get current local ip(s)
while read -r l; do
  [[ "$l" = "" ]] && continue
  currlocal["$(echo "$l"|cut -d' ' -f1)"]="$(echo "$l"|cut -d' ' -f3-)"
done <<< "$(ip --brief addr|grep -Eiv '[^a-z0-9\.\:\/ ]'|grep -E '[a-z0-9]'|grep -Ev '(^lo | DOWN )'|sed -r 's/ +/ /g')"

#skip if not online
[[ "${!currlocal[@]}" = "" ]] && break

#need new public ip if *all* local ip addresses changed
#(checking all prevents needless re-checking of external ip if i.e. switching from wired to wireless)
needcheck=1; for a in "${!currlocal[@]}"; do
  if [[ ! "${lastlocal["$a"]}" = "" ]] && [[ "${lastlocal["$a"]}" = "${currlocal["$a"]}" ]]; then
    needcheck=0; break; fi
done

#need new public ip if public ip not yet defined, or if timer is up
[[ "$needcheck" = "0" ]] && if [[ "$pubip_last" = "" ]]; then needcheck=1
elif [[ ! "$pubipdate_last" = "" ]] && \
  [[ "$(date +'%F %H:%M')" > "$(date -d "$(date -d "$pubipdate_last")+$checkpubevery hours" +'%F %H:%M')" ]]
  then needcheck=1; fi

#get new public ip/timestamp if needed
if [[ "$needcheck" = "1" ]]; then
  pubip="$(curl -s 'http://myexternalip.com/raw'|grep -Eiv '[^a-z0-9\.\:\/]')"
  if [[ "$pubip" = "" ]]; then
    msg_red "failed to get external ip"
  else pubipdate="$(date +'%F %H:%M')"
    if [[ "$pubip" = "$pubip_last" ]]; then
      msg_grn "external ip unchanged"
    else msg_yel "new external ip: $pubip"; fi
  fi
fi

#check for new info
needexport=0; if [[ ! "$pubip" = "" ]] \
  || [[ ! "${!currlocal[@]}" = "${!lastlocal[@]}" ]] \
  || [[ ! "${currlocal[@]}" = "${lastlocal[@]}" ]]
  then needexport=1
fi

[[ "$pubip" = "" ]] && pubip="$pubip_last"
[[ "$pubipdate" = "" ]] && pubipdate="$pubipdate_last"
[[ "$pubipdate" = "" ]] && pubipdate="err_no_date"

#export new info
if [[ "$needexport" = "1" ]] && [[ ! "$pubip" = "" ]]; then
  mkdir -p "$(dirname "$cachefile")"
  echo "pubip $pubip" > "$cachefile"
  echo "lastget $pubipdate" >> "$cachefile"
  for a in "${!currlocal[@]}"; do
    echo "$a ${currlocal["$a"]}" >> "$cachefile"
  done
  mkdir -p "$(dirname "$cachefile_persist")"
  cp -f "$cachefile" "$cachefile_persist"
fi

#display public ip
#pubip="12.34.56.78" #uncomment for demo ip address
[[ "$pubip" = "" ]] || echo -n "\$template0Public IP: \${color}$pubip \${color1}(Updated: \${color}$pubipdate\${color1})"


#end public ip section
break
done


#display local adapter info
for p in $(ls /sys/class/net); do
  [[ "$p" = "lo" ]] && continue
  [[ ! "${!currlocal[@]}" = "" ]] && [[ "${currlocal[$p]}" = "" ]] && newcon="\${color4}"
  conn=d; [[ -d "/sys/class/net/$p/wireless" ]] && conn=b
  echo "\${if_up $p}"; echo "\$template0\${stippled_hr}"
  echo "\$template0$newcon\${font ConkySymbols:size=16}$conn\${font}$newcon $p \${alignr}\${color}$newcon\${addr $p}"
  if [[ "$conn" = "b" ]]; then
    echo "\$template0SSID : \${color}\${wireless_essid $p} \${color1}\${alignr} \${color}\${wireless_link_qual_perc $p}% \${wireless_link_bar 7,100 $p}"
  fi
  echo -n "\$template0Speed: \${color}\${downspeed $p}\${color1}▼\${color} \${upspeed $p}\${color1}▲\${color}\${alignr}\${color1}Tot: \${color}\${totaldown $p}\${color1}▼\${color} \${totalup $p}\${color1}▲\${color0}\$endif"
unset newcon; done

exit 0


