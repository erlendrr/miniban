#!/bin/bash
cd "${0%/*}"; cd ..; MYDIR=$(pwd)


while true; do
    #henter feilede påloggingsforsøk fra ssh-loggen med X sekunder mellomrom"
    PASSFAILS_1=$(journalctl -u ssh | grep "Failed password" | awk '{print $11}' | uniq -c)
    sleep 3
    PASSFAILS_2=$(journalctl -u ssh | grep "Failed password" | awk '{print $11}' | uniq -c)

    #Deler opp og sammenligner alle forsøkene
    echo $PASSFAILS_1 | while IFS=" " read -r COUNT_1 IP; do
        echo $PASSFAILS_2 | while IFS=" " read -r COUNT_2 _IP; do

        #Hvis antall feilede forsøk har økt vil Ip'en bli lagt til i kickcount listen
        if [[ $COUNT_2 -gt $COUNT_1 ]]; then
            echo $IP >> $MYDIR/kickcount.db
            echo "IP kastet ut"
        fi

        #Hvis antall feilede forsøk i kickcount listen er over 3 for en vilkårlig IP adresse, vil den kjøres i ban-scriptet
        cat $MYDIR/kickcount.db | sort | uniq -c | while IFS=" " read -r DB_COUNT DB_IP; do
                if [[ $DB_COUNT -gt 2 ]]; then
                    $MYDIR/bin/ban.sh "$DB_IP"
                fi
            done
        done
    done
done
