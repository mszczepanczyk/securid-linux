#!/bin/bash
# Mariusz Szczepańczyk <mszczepanczyk@gmail.com>
# 2012-06-17

XVFB=/usr/bin/Xvfb
WINE=/usr/bin/wine
AUTOHOTKEY=`pwd`/AutohotKey/AutoHotKey.exe
SCRIPT=`pwd`/securid.ahk
XDISPLAY=:5

function ctrlc {
    kill -9 ${WINE_PID}
    kill -9 ${XVFB_PID}
}

# start xvfb
${XVFB} ${XDISPLAY} 2> /dev/null &
XVFB_PID=$!

# start wine
DISPLAY=${XDISPLAY} ${WINE} ${AUTOHOTKEY} ${SCRIPT} 2> /dev/null &
WINE_PID=$!

# wait for wine to finish
trap ctrlc INT
wait ${WINE_PID}

# kill xvfb
kill ${XVFB_PID} 2> /dev/null
