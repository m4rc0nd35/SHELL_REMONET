#!/bin/sh
. /usr/share/functions/api_functions.sh
WLAN_ITF="$1"
EVENT="$2"
INFO="$3"
if [ "$EVENT" == "WPS-PBC-ACTIVE" ]
then
send_wps_status "0" "1"
elif [ "$EVENT" == "WPS-TIMEOUT" ] || [ "$EVENT" == "WPS-PBC-DISABLE" ]
then
send_wps_status "0" "0"
elif [ "$EVENT" == "WPS-REG-SUCCESS" ]
then
send_wps_status "2" "$INFO"
fi
