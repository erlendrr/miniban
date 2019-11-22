#!/bin/bash
# Jeg setter miniban-folderen til en variabel, som jeg kan referere til gjennom hele programmet.
# Dette gjør at scriptet kan fungere uansett hvor det er plassert i filsystemet.
cd "${0%/*}"
cd ..
MYDIR=$(pwd)

unban() {
        # Bruker et regex utrykk for å sjekke om IP-en er ipv4
        if [[ $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                # fjerner en brannmurregel for ipv4 som sender en "reject" tilbakemedling på alle porter. Man kan bruke --dport for å begrense til port 22.
                sudo iptables -D INPUT -p tcp -s $IP -j REJECT
        # Bruker et regex utrykk for å sjekke om IP-en er ipv6
        elif [[ $IP =~ ^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$ ]]; then
                #ipv6
                sudo ip6tables D INPUT -p tcp -s $IP -j REJECT
        else
                echo "skriv inn gyldig ip"
        fi
        #fjerner ip'en fra miniban.db
        sed -i /$IP/d $MYDIR/miniban.db
        echo "$IP" er blitt godtatt på SSH
}

while true; do
        #her velger man antall sekunder
        UNBAN_DATE=$(expr $(date +%s) - 600)
        IFS=$'\n'
        for i in $(cat <$MYDIR/miniban.db); do
                IFS="," read IP TIMESTAMP
                if [[ $TIMESTAMP -lt $UNBAN_DATE ]]; then
                        unban
                fi
        done <$MYDIR/miniban.db
        sleep 2
done
