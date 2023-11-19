# heartbeat-unix

This is the Linux / macOS / Unix client for Heartbeat. It will ping the central server every minute, as long as an input device (keyboard or mouse) has been used in the last two minutes, and your device is unlocked.

# Jump to
- [Usage (for most \*NIX-like systems)](#usage-for-most-nix-like-systems)
- [Usage (for macOS)](#usage-for-macos)

## Usage (for most \*NIX-like systems)

1. Download the POSIX shell script, [`heartbeat-client-unix.sh`](https://github.com/lmaotrigine/heartbeat-unix/blob/master/scripts/heartbeat-client-unix.sh) anywhere you'd like, preferably like so
```bash
mkdir -p ~/.heartbeat/bin/
curl https://raw.githubusercontent.com/lmaotrigine/heartbeat-unix/master/scripts/heartbeat-client-unix.sh -o ~/.heartbeat/bin/heartbeat
chmod +x ~/.heartbeat/bin/heartbeat
```

Feel free to modify this however you'd like. Do note, **you *will* have to update the systemd service files** if you download it to a different location.

2. Setup config

Next, inside `~/.heartbeat/config`, add the following
```bash
export HEARTBEAT_AUTH='your heartbeat server token'
export HEARTBEAT_HOSTNAME="https://your.heartbeat.domain"
export HEARTBEAT_LOG_DIR="$HOME/.cache/heartbeat"
export HEARTBEAT_SCREEN_LOCK=kscreenlocker  # or whatever screen locker you use.
```

3. Download and install the systemd service

If you are not using systemd on your system, please use the equivalent service for your system. Do **not** use a cronjob, as that does not work with `xprintidle` (required by the script).

```bash
mkdir -p ~/.config/systemd/user/
curl https://raw.githubusercontent.com/lmaotrigine/heartbeat-unix/master/services/heartbeat-client.service -o ~/.config/systemd/user/heartbeat-client.service
curl https://raw.githubusercontent.com/lmaotrigine/heartbeat-unix/master/services/heartbeat-client.timer -o ~/.config/systemd/user/heartbeat-client.timer
# Enable the service and timer for the current user
systemctl --user enable --now heartbeat-client.timer
```

4. Ensure that the client is set up correctly

To be sure your script is working and got a response from the server, run the following commands (this makes debugging easier + faster, but you could also just watch your heartbeat server's website for an update).

```bash
. ~/.heartbeat/config
cd ~/.heartbeat/bin
./heartbeat
cat "$HEARTBEAT_LOG_DIR/heartbeat.log"
# The output should look somewhat like the following
# 2021/09/23 17:28:07 - Running Heartbeat
# 1632432488
```

## Usage (for macOS)

Since `xprintidle` does not have support for macOS, there is an alternative script available.

1. Download the bash script, [`heartbeat-client-macOS.sh`](https://github.com/lmaotrigine/heartbeat-unix/blob/master/scripts/heartbeat-client-macOS.sh) anywhere you'd like, preferably like so
```bash
mkdir -p ~/.heartbeat/bin/
curl https://raw.githubusercontent.com/lmaotrigine/heartbeat-unix/master/scripts/heartbeat-client-macOS.sh -o ~/.heartbeat/bin/heartbeat
chmod +x ~/.heartbeat/bin/heartbeat
```

Feel free to modify this however you'd like. Do note, **you *will* have to update the plist file** if you download it to a different location.

2. Setup config

Next, inside `~/.heartbeat/config`, add the following
```bash
export HEARTBEAT_AUTH='your heartbeat server token'
export HEARTBEAT_HOSTNAME="https://your.heartbeat.domain"
export HEARTBEAT_LOG_DIR="$HOME/Library/Logs/net.lmaotrigine.heartbeat"
```

3. Copy `net.lmaotrigine.heartbeat.plist` to `~/Library/LaunchAgents`.
4. Run `launchctl load ~/Library/LaunchAgents/net.lmaotrigine.heartbeat.plist`.
5. Ensure that the client is set up correctly

To be sure your script is working and got a response from the server, run the following commands (this makes debugging easier + faster, but you could also just watch your heartbeat server's website for an update).

```bash
. ~/.heartbeat/config
cd ~/.heartbeat/bin
./heartbeat
cat "$HEARTBEAT_LOG_DIR/heartbeat.log"
# The output should look somewhat like the following
# 2021/09/23 17:28:07 - Running Heartbeat
# 1632432488
```
