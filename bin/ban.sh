#!/bin/bash
# Jeg setter miniban-folderen til en variabel, som jeg kan referere til gjennom hele programmet.
# Dette gjør at scriptet kan fungere uansett hvor det er plassert i filsystemet.
cd "${0%/*}"
cd ..
MYDIR=$(pwd)

#brukeren kan bannlyse ip'er manuelt
IP=$1
TIMESTAMP=$(date +%s)

banning() {
        if [[ ($(grep -c $IP $MYDIR/whitelist.db) -eq 0) ]]; then
                if [[ ($(grep -c $IP $MYDIR/miniban.db) -eq 0) ]]; then
                        sed -i /$IP/d $MYDIR/kickcount.db
                        echo "$IP,$TIMESTAMP" >>$MYDIR/miniban.db
                        echo "$IP har blitt blokkert fra SSH"
                else
                        echo "$IP er allerede bannet"
                fi
        else
                sed -i /$IP/d $MYDIR/kickcount.db
                echo "$IP er på whitelist"
        fi
}

# sjekker om ip er ipv4
# Jeg gjør dette for å bruke rett iptables kommando og fordi validere brukerinput
if [[ $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        # legger til brannmurregel for ipv4 som sender en "reject" tilbakemedling på alle porter. Man kan bruke --dport for å begrense til port 22.
        sudo iptables -A INPUT -p tcp -s $IP -j REJECT
        banning
        # sjekker om ip er ipv6
elif [[ $IP =~ ^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$ ]]; then
        sudo ip6tables -A INPUT -p tcp -s $IP -j REJECT
        banning
else
        echo "skriv inn gyldig ip"
fi
