#!/bin/bash
cd "${0%/*}"
cd ..
MYDIR=$(pwd)

trap 'kill $(jobs -p)' EXIT TERM
$MYDIR/bin/unban.sh &

while true; do
    #journalctl -f -n 0 -u ssh
    PASSFAILS_1=$(journalctl -u ssh --since "10 minutes ago" | grep "Failed password" | awk '{print $11}' | sort | uniq -c)
    sleep 0.1
    PASSFAILS_2=$(journalctl -u ssh --since "10 minutes ago" | grep "Failed password" | awk '{print $11}' | sort | uniq -c)

    echo $PASSFAILS_1 | tr " " "\n" | paste -d ' ' - - | while read COUNT_1 IP; do
        echo $PASSFAILS_2 | tr " " "\n" | paste -d ' ' - - | while read COUNT_2 _IP; do
            echo "første: $COUNT_1 $IP"
            echo "andre: $COUNT_2 $_IP"

            if [[ ($COUNT_2 -gt $COUNT_1) && ($IP == $_IP) && ($(grep -c $IP $MYDIR/miniban.db) -eq 0) ]]; then
                echo $IP >>$MYDIR/kickcount.db
                echo "$IP kastet ut"
            fi

            cat $MYDIR/kickcount.db | sort | uniq -c | while IFS=" " read -r DB_COUNT DB_IP; do
                if [[ $DB_COUNT -gt 2 ]]; then
                    echo "ban"
                    $MYDIR/bin/ban.sh "$DB_IP"
                fi
            done
        done
    done
done

wait
