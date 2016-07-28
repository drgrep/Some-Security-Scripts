#
# port_monitoring.sh - simple script for port monitoring, etc..   
#
# Copyright (C) 10/11/2015 Dr. Grep - www.doctorgrep.com
# 
# Input parameters: $1 scan speed(T1..T4) $2 ports $3 assets_file $4 email recipient
#

#!/bin/bash

if [ -f "open_ports" ]
then
  rm -f "open_ports"
else 
  first_scan="true"
fi
[[ -f "diff_ports" ]] && rm -f "diff_ports"
for i in `cat $3`; do
  [[ -f "$i"_new ]] && mv "$i"_new "$i"_old;
  echo "############# $i #############" > "$i"_new; 
  nmap -$1 -Pn -nR -p `cat $2` --open $i >> "$i"_new;
  cat "$i"_new >> open_ports
  [[ -f "$i"_old ]] && difference=`diff "$i"_old "$i"_new | egrep "(tcp|udp)"`
  if [ "$difference" != "" ]
  then
    echo "############# $i #############" >> diff_ports
    echo $difference >> diff_ports
  fi
done
if [ "$first_scan" = "true" ]
then
  sendEmail -f yourmail@domain.com -t $4 -u "Info: First scan finished successfully" -o message-file=open_ports -s authsmtp.domain.com:25 -xu yourmail@domain.com -xp password
  exit 0
fi
if [ -f diff_ports ]
  then [[ -f body$3 ]] && rm -f body$3
   echo "-----------------Ports Changed-------------------" >  body$3
   cat diff_ports >> body$3
   echo >> body$3
   echo "-----------------Open ports----------------------" >> body$3
   cat open_ports >> body$3
   sendEmail -f yourmail@domain.com -t $4 -u "Alert: Ports changed" -o message-file=body$3 -s authsmtp.domain.com:25 -xu yourmail@domain.com -xp password
else sendEmail -f yourmail@domain.com -t $4 -u "Info: No port change" -m "No port change, scan finished successfully" -s authsmtp.domain.com:25 -xu yourmail@domain.com -xp password
fi
