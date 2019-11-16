#!/bin/bash
cd "${0%/*}"; cd ..; MYDIR=$(pwd)

getBanCount() {
cat $MYDIR/bancounter.db
}

while true; do
    PASSFAILS_1=$(journalctl -u ssh | grep "Failed password" | awk '{print $11}' | uniq -c)
    sleep 3
    clear
    PASSFAILS_2=$(journalctl -u ssh | grep "Failed password" | awk '{print $11}' | uniq -c)

    echo $PASSFAILS_1 | while IFS=" " read -r COUNT_1 IP; do
        echo $PASSFAILS_2 | while IFS=" " read -r COUNT_2 _IP; do
        echo "count_1: $COUNT_1"
        echo "count_2: $COUNT_2"
        echo "ip: $IP"

        if [[ $COUNT_2 -gt $COUNT_1 ]]; then
                FAILS=$(expr $COUNT_2 - $COUNT_1)
                echo $FAILS $IP >> $MYDIR/bancounter.db
                
            fi
        done
    done
done
#echo $PASSFAILS_2 | while IFS=" " read -r COUNT_2 IP_2; do
   #         if [[ $COUNT_2 -gt $COUNT_1 ]]; then
  #          echo $IP
 #           fi
#        done
