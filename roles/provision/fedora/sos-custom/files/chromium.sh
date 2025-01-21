#!/usr/bin/bash
url="file:///usr/share/signageos/client/index.html"
user_data_dir=/var/lib/chromium

CHROMIUM_EXECUTABLE="/usr/bin/chromium-browser"

debug_port=9999
command_args=""
# need to figure out why this wont work... 
#command_args="$command_args --ozone-platform=wayland"
#command_args="$command_args --enable-features=UseOzonePlatform"
command_args="$command_args --kiosk"
command_args="$command_args --noerrdialogs"
command_args="$command_args --disable-features=TranslateUI"
command_args="$command_args --disable-popup-blocking"
command_args="$command_args --no-sandbox"
command_args="$command_args --user-data-dir=$user_data_dir"
command_args="$command_args --enable-logging=stderr"
command_args="$command_args --remote-debugging-port=$debug_port"
command_args="$command_args --disable-gpu-driver-bug-workarounds"
command_args="$command_args --disable-gpu-process-crash-limit"
command_args="$command_args --disable-sync"
command_args="$command_args --disable-background-networking"
command_args="$command_args --disable-background-timer-throttling"
command_args="$command_args --disable-backgrounding-occluded-windows"
command_args="$command_args --disable-component-update"
command_args="$command_args --disable-crash-reporter"
command_args="$command_args --disable-renderer-accessibility"
command_args="$command_args --disable-dev-shm-usage"
command_args="$command_args --no-default-browser-check"
command_args="$command_args --disable-pinch"
command_args="$command_args --disable-logging"

# Disables CORS and some other security features that don't make sense in digital signage context
# https://stackoverflow.com/questions/3102819/disable-same-origin-policy-in-chrome
command_args="$command_args --disable-web-security"

# Disables error 'Blocked a frame with origin "xxx" from accessing a cross-origin frame.'
# https://github.com/cypress-io/cypress/issues/1951#issuecomment-401579981
command_args="$command_args --disable-site-isolation-trials"


exec sudo $CHROMIUM_EXECUTABLE $command_args $url

