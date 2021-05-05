#!/bin/sh
. /usr/share/libubox/jshn.sh
# . /usr/share/device_functions.sh
get_hwmode_24() {
    local _htmode_24="$(uci -q get wireless.radio0.htmode)"
    [ "$_htmode_24" = "NOHT" ] && echo "11g" || echo "11n"
}
get_htmode_24() {
    local _htmode_24="$(uci -q get wireless.radio0.htmode)"
    local _noscan_24="$(uci -q get wireless.radio0.noscan)"
    if [ "$_noscan_24" == "0" ]
    then
        [ "$_htmode_24" = "HT40" ] && echo "auto" || echo "HT20"
    else
        [ "$_htmode_24" = "HT40" ] && echo "HT40" || echo "HT20"
    fi
}
get_htmode_50() {
    local _htmode_50="$(uci -q get wireless.radio1.htmode)"
    local _noscan_50="$(uci -q get wireless.radio1.noscan)"
    [ "$_noscan_50" == "0" ] && echo "auto" || echo "$_htmode_50"
}
get_wifi_htmode(){
    iw dev wlan$1 info 2>/dev/null|grep width|awk '{print $6}'
}
check_connectivity_internet() {
    _addrs="www.google.com.br"$'\n'"www.facebook.com"$'\n'"www.globo.com"
    if [ "$1" != "" ]
    then
        _addrs="$1"
    fi
	echo $_addrs
    for _addr in $_addrs
    do
        if ping -q -c 1 -w 2 "$_addr"  > /dev/null 2>&1
        then
            echo 0
            return
        fi
    done
    echo 1
    return
}
get_wifi_info() {
    json_cleanup
    json_init
    local _hwmode=$(uci -q get wireless.radio0.hwmode)
    local _htmode=$(uci -q get wireless.radio0.htmode)
    local _txpower=$(uci -q get wireless.radio0.txpower)
    local _noscan=$(uci -q get wireless.radio0.noscan)
    local _country=$(uci -q get wireless.radio0.country)
    local _channel=$(uci -q get wireless.radio0.channel)
    local _channels=$(uci -q get wireless.radio0.channels)
    local _disabled=$(uci -q get wireless.radio0.disabled)
    local _ssid=$(uci -q get wireless.default_radio0.ssid)
    local _mode=$(uci -q get wireless.default_radio0.mode)
    local _hidden=$(uci -q get wireless.default_radio0.hidden)
    local _encryption=$(uci -q get wireless.default_radio0.encryption)
    local _disassoc_low_ack=$(uci -q get wireless.default_radio0.disassoc_low_ack)
    local _wps_pushbutton=$(uci -q get wireless.default_radio0.wps_pushbutton)
    local _wps_manufacturer=$(uci -q get wireless.default_radio0.wps_manufacturer)
    local _wps_device_name=$(uci -q get wireless.default_radio0.wps_device_name)
    json_add_object wifi2
    json_add_string "hwmode" "$_hwmode"
    json_add_string "htmode" "$_htmode"
    json_add_string "txpower" "$_txpower"
    json_add_string "noscan" "$_noscan"
    json_add_string "country" "$_country"
    json_add_string "channel" "$_channel"
    json_add_string "channels" "$_channels"
    json_add_int "disabled" "$_disabled"
    json_add_string "ssid" "$_ssid"
    json_add_string "mode" "$_mode"
    json_add_string "hidden" "$_hidden"
    json_add_string "encryption" "$_encryption"
    json_add_string "disassoc_low_ack" "$_disassoc_low_ack"
    json_add_string "wps_pushbutton" "$_wps_pushbutton"
    json_add_string "wps_device_name" "$_wps_device_name"
    json_close_object
    if [ "$(uci -q get wireless.default_radio1.ssid)" ]
    then
        local _hwmode5=$(uci -q get wireless.radio1.hwmode)
        local _htmode5=$(uci -q get wireless.radio1.htmode)
        local _txpower5=$(uci -q get wireless.radio1.txpower)
        local _noscan5=$(uci -q get wireless.radio1.noscan)
        local _country5=$(uci -q get wireless.radio1.country)
        local _channel5=$(uci -q get wireless.radio1.channel)
        local _channels5=$(uci -q get wireless.radio1.channels)
        local _disabled5=$(uci -q get wireless.radio1.disabled)
        local _ssid5=$(uci -q get wireless.default_radio1.ssid)
        local _mode5=$(uci -q get wireless.default_radio1.mode)
        local _hidden5=$(uci -q get wireless.default_radio1.hidden)
        local _encryption5=$(uci -q get wireless.default_radio1.encryption)
        local _disassoc_low_ack5=$(uci -q get wireless.default_radio1.disassoc_low_ack)
        local _wps_pushbutton5=$(uci -q get wireless.default_radio1.wps_pushbutton)
        local _wps_manufacture5r=$(uci -q get wireless.default_radio1.wps_manufacturer)
        local _wps_device_name5=$(uci -q get wireless.default_radio1.wps_device_name)
        json_add_object wifi5
        json_add_string "hwmode" "$_hwmode5"
        json_add_string "htmode" "$_htmode5"
        json_add_string "txpower" "$_txpower5"
        json_add_string "noscan" "$_noscan5"
        json_add_string "country" "$_country5"
        json_add_string "channel" "$_channel5"
        json_add_string "channels" "$_channels5"
        json_add_int "disabled" "$_disabled5"
        json_add_string "ssid" "$_ssid5"
        json_add_string "mode" "$_mode5"
        json_add_string "hidden" "$_hidden5"
        json_add_string "encryption" "$_encryption5"
        json_add_string "disassoc_low_ack" "$_disassoc_low_ack5"
        json_add_string "wps_pushbutton" "$_wps_pushbutton5"
        json_add_string "wps_device_name" "$_wps_device_name5"
        json_close_object
    fi
	echo "WIFI2;$_hwmode;$_htmode;$_txpower;$_noscan;$_country;$_channel;$_channels;$_disabled;$_ssid;$_mode;$_hidden;$_encryption;$_disassoc_low_ack;$_wps_pushbutton;$_wps_manufacturer;$_wps_device_name"
    # json_dump
}
get_wifi_channel(){
    iw dev wlan$1 info 2>/dev/null|grep channel|awk '{print $2}'
}
auto_channel_selection() {
    local _iface=$1
    case "$_iface" in
        wlan0)
            echo "6"
        ;;
        wlan1)
            echo "40"
        ;;
    esac
}
get_txpower() {
    local _freq="$1"
    local _txpower="$(uci -q get wireless.radio$_freq.txpower)"
    local _channel="$(uci -q get wireless.radio$_freq.channel)"
    if [ "$_channel" = "auto" ]
    then
        echo "100"
        return
    fi
    local _phy
    local _maxpwr="0"
    if [ "$_freq" = "0" ]
    then
        _phy=$(get_24ghz_phy)
        [ "$(type -t custom_wifi_24_txpower)" ] && _maxpwr="$(custom_wifi_24_txpower)"
    else
        _phy=$(get_5ghz_phy)
        [ "$(type -t custom_wifi_50_txpower)" ] && _maxpwr="$(custom_wifi_50_txpower)"
    fi
    [ "$_maxpwr" = "0" ] && _maxpwr=$(iw $_phy info | awk '/\['$_channel'\]/{ print substr($5,2,2) }')
    local _txprct="$(( (_txpower * 100) / _maxpwr ))"
    if   [ $_txprct -ge 100 ]; then echo "100"
        elif [ $_txprct -ge 75 ]; then echo "75"
        elif [ $_txprct -ge 50 ]; then echo "50"
    else echo "25"
    fi
}
change_fast_transition() {
    local _radio="$1"
    local _enabled="$2"
    if [ "$_enabled" = "1" ]
    then
        uci set wireless.default_radio$_radio.ieee80211r="1"
        uci set wireless.default_radio$_radio.ieee80211v="1"
        uci set wireless.default_radio$_radio.bss_transition="1"
        uci set wireless.default_radio$_radio.ieee80211k="1"
    else
        uci delete wireless.default_radio$_radio.ieee80211r
        uci delete wireless.default_radio$_radio.ieee80211v
        uci delete wireless.default_radio$_radio.bss_transition
        uci delete wireless.default_radio$_radio.ieee80211k
    fi
}
get_wifi_local_config() {
    local _ssid_24="$(uci -q get wireless.default_radio0.ssid)"
    local _password_24="$(uci -q get wireless.default_radio0.key)"
    local _channel_24="$(uci -q get wireless.radio0.channel)"
    local _curr_channel_24="$(get_wifi_channel '0')"
    local _hwmode_24="$(get_hwmode_24)"
    local _htmode_24="$(get_htmode_24)"
    local _curr_htmode_24="$(get_wifi_htmode '0')"
    local _state_24="$(get_wifi_state '0')"
    local _txpower_24="$(get_txpower 0)"
    local _ft_24="$(uci -q get wireless.default_radio0.ieee80211r)"
    local _hidden_24="$(uci -q get wireless.default_radio0.hidden)"
    local _is_5ghz_capable="$(is_5ghz_capable)"
    local _ssid_50=""
    local _password_50=""
    local _channel_50=""
    local _curr_channel_50=""
    local _hwmode_50=""
    local _htmode_50=""
    local _curr_htmode_50=""
    local _state_50=""
    local _txpower_50=""
    local _ft_50=""
    local _hidden_50=""
    if [ "$_is_5ghz_capable" = "1" ]
    then
        _ssid_50="$(uci -q get wireless.default_radio1.ssid)"
        _password_50="$(uci -q get wireless.default_radio1.key)"
        _channel_50="$(uci -q get wireless.radio1.channel)"
        _curr_channel_50="$(get_wifi_channel '1')"
        _hwmode_50="$(uci -q get wireless.radio1.hwmode)"
        _htmode_50="$(get_htmode_50)"
        _curr_htmode_50="$(get_wifi_htmode '1')"
        _state_50="$(get_wifi_state '1')"
        _txpower_50="$(get_txpower 1)"
        _ft_50="$(uci -q get wireless.default_radio1.ieee80211r)"
        _hidden_50="$(uci -q get wireless.default_radio1.hidden)"
    fi
    json_cleanup
    json_init
    json_add_string "local_ssid_24" "$_ssid_24"
    json_add_string "local_password_24" "$_password_24"
    json_add_string "local_channel_24" "$_channel_24"
    json_add_string "local_curr_channel_24" "$_curr_channel_24"
    json_add_string "local_hwmode_24" "$_hwmode_24"
    json_add_string "local_htmode_24" "$_htmode_24"
    json_add_string "local_curr_htmode_24" "$_curr_htmode_24"
    json_add_string "local_ft_24" "$_ft_24"
    json_add_string "local_state_24" "$_state_24"
    json_add_string "local_txpower_24" "$_txpower_24"
    json_add_string "local_hidden_24" "$_hidden_24"
    json_add_string "local_5ghz_capable" "$_is_5ghz_capable"
    json_add_string "local_ssid_50" "$_ssid_50"
    json_add_string "local_password_50" "$_password_50"
    json_add_string "local_channel_50" "$_channel_50"
    json_add_string "local_curr_channel_50" "$_curr_channel_50"
    json_add_string "local_hwmode_50" "$_hwmode_50"
    json_add_string "local_htmode_50" "$_htmode_50"
    json_add_string "local_curr_htmode_50" "$_curr_htmode_50"
    json_add_string "local_ft_50" "$_ft_50"
    json_add_string "local_state_50" "$_state_50"
    json_add_string "local_txpower_50" "$_txpower_50"
    json_add_string "local_hidden_50" "$_hidden_50"
    json_dump
    json_close_object
}
save_wifi_parameters() {
    json_cleanup
    json_load_file /root/flashbox_config.json
    json_add_string ssid_24 "$(uci -q get wireless.default_radio0.ssid)"
    json_add_string password_24 "$(uci -q get wireless.default_radio0.key)"
    json_add_string channel_24 "$(uci -q get wireless.radio0.channel)"
    json_add_string hwmode_24 "$(uci -q get wireless.radio0.hwmode)"
    json_add_string htmode_24 "$(get_htmode_24)"
    json_add_string state_24 "$(get_wifi_state '0')"
    json_add_string txpower_24 "$(get_txpower 0)"
    json_add_string hidden_24 "$(uci -q get wireless.default_radio0.hidden)"
    if [ "$(is_5ghz_capable)" == "1" ]
    then
        json_add_string ssid_50 "$(uci -q get wireless.default_radio1.ssid)"
        json_add_string password_50 "$(uci -q get wireless.default_radio1.key)"
        json_add_string channel_50 "$(uci -q get wireless.radio1.channel)"
        json_add_string hwmode_50 "$(uci -q get wireless.radio1.hwmode)"
        json_add_string htmode_50 "$(get_htmode_50)"
        json_add_string state_50 "$(get_wifi_state '1')"
        json_add_string txpower_50 "$(get_txpower 1)"
        json_add_string hidden_50 "$(uci -q get wireless.default_radio1.hidden)"
    fi
    json_dump > /root/remonet_config.json
    json_close_object
}
