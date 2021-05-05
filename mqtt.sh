#!/bin/sh
. /usr/share/functions/wireless_functions.sh
. /usr/share/init.conf
case "$1" in
    reqstatus)
        echo "MQTTMSG" "Running Update"
        sh /usr/share/flashman_update.sh $2
    ;;
    reboot)
        echo "MQTTMSG" "Rebooting"
        /sbin/reboot
    ;;
    set_ssid_2g)
        echo "Set ssid WIFI 2G"
        change_ssid_2g
    ;;
    set_passwd_2g)
        echo "Set password WIFI 2G"
        set_passwd_2g_uci $2
    ;;
    set_ssid_g5)
        echo "Set ssid WIFI 5G"
        change_ssid_5g
    ;;
    set_passwd_5g)
        echo "Set password WIFI 5G"
        run_ping_ondemand_test
    ;;
    connectivity)
        echo "MQTTMSG" "Changing Zabbix PSK settings"
        check_connectivity_internet
    ;;
    wifi_info)
        # echo "MQTTMSG" "Changing wireless radio state"
        get_wifi_info
    ;;
    *)
        echo "MQTTMSG $FLM_SVADDR Cant recognize message: $1"
    ;;
esac
