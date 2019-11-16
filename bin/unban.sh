#!/bin/bash
DBFILE="/home/bruker/miniban/miniban.db"
while true; do
UNBAN_DATE=$(expr $(date +%s) - 10)
IFS=$'\n'
for i in $(cat < $DBFILE); do
        IFS="," read IP TIMESTAMP
        if [[ $TIMESTAMP -lt $UNBAN_DATE ]]; then
        sudo iptables -A INPUT -p tcp -s $IP --dport 22 -j DROP
        sudo ip6tables -A INPUT -p tcp -s $IP --dport 22 -j DROP
                sed -i /$IP/d $DBFILE
        fi
done < $DBFILE
sleep 2
done