#!/usr/bin/env sh

if ! [ -e "$HOME/.env" ]; then
    echo "$HOME/.env not setup, please create it"
    exit 1
fi

# shellcheck source=/dev/null
. "$HOME/.env"
HEARTBEAT_LOG_DIR="${HEARTBEAT_LOG_DIR:-$HOME/Library/Logs/net.lmaotrigine.heartbeat}"

if [ -z "$HEARTBEAT_AUTH" ] || [ -z "$HEARTBEAT_HOSTNAME" ]; then
    echo "Environment variables not setup correctly!"
    echo "HEARTBEAT_AUTH: $HEARTBEAT_AUTH"
    echo "HEARTBEAT_LOG_DIR: $HEARTBEAT_LOG_DIR"
    echo "HEARTBEAT_HOSTNAME: $HEARTBEAT_HOSTNAME"
    exit 1
else
    # Make log dir if it doesn't exist
    if ! [ -d "$HEARTBEAT_LOG_DIR" ]; then
        mkdir -p "$HEARTBEAT_LOG_DIR" || exit 1
    fi

    # Check when the last HID event was sent
    LAST_INPUT_SEC="$(($(ioreg -c IOHIDSystem | sed -e '/HIDIdleTime/ !{ d' -e 't' -e '}' -e 's/.* = //g' -e 'q') / 1000000000))"

    # Launchd will not execute the task if the system is locked or sleeping, so no need to worry about the screen lock state
    if [ $LAST_INPUT_SEC -lt 120 ]; then
        {
            echo "$(date +"%Y/%m/%d %T") - Running Heartbeat"
            curl -s -X POST -H "Authorization: $HEARTBEAT_AUTH" "$HEARTBEAT_HOSTNAME/api/beat"
            echo ""
        } >> "$HEARTBEAT_LOG_DIR/heartbeat.log" 2>&1
    fi
fi
