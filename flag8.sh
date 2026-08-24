#!/bin/bash
# Vary one byte at a time in AABBCCDDEEFF, watch for a response that
# ISN'T a plain echo of what we sent.

MAC="D4:E9:F4:B1:57:62"
BASE=(AA BB CC DD EE FF)

for pos in 0 1 2 3 4 5; do
    for i in $(seq 0 255); do
        byte=$(printf "%02X" "$i")
        payload=("${BASE[@]}")
        payload[$pos]=$byte
        hexstr=$(IFS=; echo "${payload[*]}")

        out=$(timeout 5 gatttool -b "$MAC" --char-write-req -a 0x002c -n "$hexstr" --listen 2>&1)
        indication=$(echo "$out" | grep -i "value:" | sed 's/.*value: //' | tr -d ' \n')
        sent=$(echo "$hexstr" | tr 'A-F' 'a-f')

        # only print if the response doesn't just echo what we sent
        if [[ -n "$indication" && "$indication" != "$sent"* ]]; then
            echo "pos=$pos byte=$byte -> sent=$hexstr got=$indication  <-- DIFFERENT"
        fi
    done
done

echo "Sweep done. Any line above = worth investigating."
