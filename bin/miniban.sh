#!/bin/bash
cd "${0%/*}"; cd ..; mydir=$(pwd)

while true; do
PASSFAILS=$(journalctl -u ssh | grep "Failed password" | awk '{print $11}' | uniq -c)
getBanCount() {
cat $mydir/bancounter.db
}

echo $IPLIST | while IFS=" " read -r COUNT IP; do
    if [[ $COUNT -gt 3 ]]; then
        echo $IP
    fi
done
sleep 1
done