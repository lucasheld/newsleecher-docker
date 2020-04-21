#!/bin/bash

export DISPLAY=:0

start_nl() {
    wineserver -k
    wine "C:\Program Files\NewsLeecher\newsLeecher.exe" &
}

is_nl_running() {
    ID=$(obxprop --root | grep "^_NET_ACTIVE_WINDOW" | cut -d' ' -f3)
    obxprop --id $ID >/dev/null 2>&1
    echo $?
}

# custom replacement for the KEEP_APP_RUNNING=1 option, which does not work here
while true
do
    if [ $(is_nl_running) -ne 0 ]
    then
        start_nl
    fi
    sleep 1
done
