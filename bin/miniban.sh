#!/bin/bash
# Jeg setter miniban-folderen til en variabel, som jeg kan referere til gjennom hele programmet.
# Dette gjør at scriptet kan fungere uansett hvor det er plassert i filsystemet.
cd "${0%/*}"
cd ..
MYDIR=$(pwd)

echo "Miniban har startet!"

# Her bruker jeg "trap" kommandoen for å avslutte unban-prosessen når noen går ut av programmet.
trap 'kill $(jobs -p)' EXIT TERM
$MYDIR/bin/unban.sh &

# Her henter jeg ut alle feilede loginforsøk på ssh de siste 10 minuttene.
# Deretter henter jeg ut IP-adressen og teller hvor mange gang den ip-adressen har prøvd å logge seg på.
while true; do
    PASSFAILS_1=$(journalctl -u ssh --since "10 minutes ago" | grep "Failed password" | awk '{print $11}' | sort | uniq -c)
    sleep 0.5
    # Her henter jeg ut den samme informasjonen, men 0.1 sekund etterpå.
    PASSFAILS_2=$(journalctl -u ssh --since "10 minutes ago" | grep "Failed password" | awk '{print $11}' | sort | uniq -c)

    # Sammenlikner IP-adressene og antall mislykkede forsøk med den første og andre variabelen.
    echo $PASSFAILS_1 | tr " " "\n" | paste -d ' ' - - | while read COUNT_1 IP; do
        echo $PASSFAILS_2 | tr " " "\n" | paste -d ' ' - - | while read COUNT_2 _IP; do
            # Hvis antallet feilede IP-forsøk har økt fra den første variabelen, vil den legge den til i en fil
            # Vi har oppdaget at noen ganger så vil ikke den første gangen registreres.
            if [[ ($COUNT_2 -gt $COUNT_1) && ($IP == $_IP) && ($(grep -c $IP $MYDIR/miniban.db) -eq 0) ]]; then
                echo $IP >>$MYDIR/kickcount.db
                echo "$IP kastet ut"
            fi

            # Sjekker kickcount.db
            # Hvis antallet IP-adresser i kickfilen overskreder 2, vil den automatisk kjøre (ban-kommandoen) på IP-adressen
            cat $MYDIR/kickcount.db | sort | uniq -c | while IFS=" " read -r DB_COUNT DB_IP; do
                if [[ $DB_COUNT -gt 2 ]]; then
                    $MYDIR/bin/ban.sh "$DB_IP"
                fi
            done
        done
    done
done

wait
