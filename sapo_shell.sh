#!/bin/sh

. /usr/share/functions/common_functions.sh
. /usr/share/functions/network_functions.sh
. /usr/share/functions/device_functions.sh
. /usr/share/functions/wireless_functions.sh

[ "$#" -eq 4 ] && _master="$4" || _master=""
_status="$3"
_mac="$2"

case "$1" in
ADD)
	[ "$_status" -eq "10" ] && [ "$(is_mesh_master)" = "1" ] && \
		[ "$_master" != "$(get_mac)" ] && sleep 5 && set_mesh_slaves "$_mac"
	[ "$_status" -ge "30" ] && set_mesh_rrm
	;;
UPDATE)
	[ "$_status" -ge "30" ] && set_mesh_rrm
	;;
STATUS)
	;;
*)
	log "SAPO" "Cant recognize message: $1"
	;;
esac
