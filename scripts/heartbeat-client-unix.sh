#!/usr/bin/env sh

if ! [ -e "$HOME/.heartbeat" ]; then
    echo "$HOME/.heartbeat not setup, please create it"
    exit 1
fi

HEARTBEAT_LOG_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/heartbeat"
# shellcheck source=/dev/null
. "$HOME/.heartbeat"

if [ -z "$HEARTBEAT_AUTH" ] || [ -z "$HEARTBEAT_HOSTNAME" ]; then
    echo "Environment variables not setup correctly!"
    echo "HEARTBEAT_AUTH: $HEARTBEAT_AUTH"
    echo "HEARTBEAT_LOG_DIR: $HEARTBEAT_LOG_DIR"
    echo "HEARTBEAT_HOSTNAME: $HEARTBEAT_HOSTNAME"
    exit 1
else
    if [ -z "$(which xprintidle)" ]; then
        echo "xprintidle not found, please install it!"
        exit 1
    fi

    # Check if kscreenlocker is running. Only works on KDE
    SCREEN_LOCKED="$(pgrep kscreenlocker)"
    # Check when the last keyboard or mouse event was sent
    LAST_INPUT_MS="$(xprintidle)"

    # Make sure the device was used in the last 2 minutes
    # and make sure screen is unlocked
    if [ "$LAST_INPUT_MS" -lt 120000 ] && [ -z "$SCREEN_LOCKED" ]; then
        {
            echo "$(date +"%Y/%m/%d %T") - Running Heartbeat"
            curl -s -X POST -H "Authorization: $HEARTBEAT_AUTH" -H "$HEARTBEAT_HOSTNAME/api/beat"
            echo ""
        } >> "$HEARTBEAT_LOG_DIR/heartbeat.log" 2>&1
    fi
fi
