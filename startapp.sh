#!/bin/bash

export DISPLAY=:0

chown -R $USER_ID:$GROUP_ID $WINEPREFIX

# download and install newsleecher
wget -qO /tmp/newsleecher.exe $NEWSLEECHER_URL
wine /tmp/newsleecher.exe /SILENT
rm /tmp/newsleecher.exe

# modify wine to run newsleecher
winetricks winxp
wine reg.exe ADD "HKEY_CURRENT_USER\Software\Wine\DllOverrides" "/v" "dxgi" "/t" "REG_SZ" "/d" ""

# start newsleecher
wineserver -k
wine "C:\Program Files\NewsLeecher\newsLeecher.exe"
