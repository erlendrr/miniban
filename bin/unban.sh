#!/bin/bash
cd "${0%/*}"
cd ..
MYDIR=$(pwd)

unban() {
        if [[ $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                sudo iptables -D INPUT -p tcp -s $IP -j REJECT
        elif [[ $IP =~ ^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$ ]]; then
                sudo ip6tables D INPUT -p tcp -s $IP -j REJECT
        else
                echo "skriv inn gyldig ip"
        fi
        sed -i /$IP/d $MYDIR/miniban.db
        echo "$IP" er blitt godtatt på SSH
}       

while true; do
        #velg sekunder
        UNBAN_DATE=$(expr $(date +%s) - 10)
        IFS=$'\n'
        for i in $(cat <$MYDIR/miniban.db); do
                IFS="," read IP TIMESTAMP
                if [[ $TIMESTAMP -lt $UNBAN_DATE ]]; then
                        unban
                fi
        done <$MYDIR/miniban.db
        sleep 2
done
