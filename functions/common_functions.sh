#!/bin/sh
. /usr/share/flashman_init.conf
. /usr/share/libubox/jshn.sh
. /usr/share/functions/device_functions.sh
log() {
    logger -t "$1 " "$2"
}
sh_timeout() {
    cmd="$1"
    timeout="$2"
    (
        eval "$cmd" &
        child=$!
        trap -- "" SIGTERM
        (
            sleep "$timeout"
            kill $child 2> /dev/null
        ) &
        wait $child
    )
}
get_flashbox_version() {
    echo "$(cat /etc/anlix_version)"
}
get_uptime() {
    uptime | egrep -o 'up*.*[0-9]+:[0-9]+|up*.*[0-9]+\smin'
}
get_hardware_model() {
    if [ "$(type -t get_custom_hardware_model)" ]
    then
        get_custom_hardware_model
    else
        echo "$(cat /tmp/sysinfo/model | awk '{ print toupper($2) }')"
    fi
}
get_hardware_version() {
    if [ "$(type -t get_custom_hardware_version)" ]
    then
        get_custom_hardware_version
    else
        echo "$(cat /tmp/sysinfo/model | awk '{ print toupper($3) }')"
    fi
}
set_mqtt_secret() {
    json_cleanup
    json_load_file /root/flashbox_config.json
    json_get_var _mqtt_secret mqtt_secret
    json_close_object
    if [ "$_mqtt_secret" != "" ]
    then
        echo "$_mqtt_secret"
    else
        local _rand=$(head /dev/urandom | tr -dc A-Z-a-z-0-9)
        local _mqttsec=${_rand:0:32}
        local _data="id=$(get_mac)&mqttsecret=$_mqttsec"
        local _url="deviceinfo/mqtt/add"
        local _res=$(rest_flashman "$_url" "$_data")
        _retstatus=$?
        if [ $_retstatus -eq 0 ]
        then
            json_cleanup
            json_load "$_res"
            json_get_var _is_registered is_registered
            json_close_object
            if [ "$_is_registered" = "1" ]
            then
                json_cleanup
                json_load_file /root/flashbox_config.json
                json_add_string mqtt_secret $_mqttsec
                json_dump > /root/flashbox_config.json
                json_get_var _mqtt_secret mqtt_secret
                json_close_object
                echo "$_mqtt_secret"
            fi
        fi
    fi
}
reset_mqtt_secret() {
    json_cleanup
    json_load_file /root/flashbox_config.json
    json_get_var _mqtt_secret mqtt_secret
    if [ "$_mqtt_secret" != "" ]
    then
        json_add_string mqtt_secret ""
        json_dump > /root/flashbox_config.json
    fi
    json_close_object
    set_mqtt_secret
}
rest_flashman() {
    local _url=$1
    local _data=$2
    local _res
    local _curl_out
    _res=$(curl -s \
        -A "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)" \
        --tlsv1.2 --connect-timeout 5 --retry 1 \
        --data "$_data&secret=$FLM_CLIENT_SECRET" \
    "https://$FLM_SVADDR/$_url")
    _curl_out=$?
    if [ "$_curl_out" -eq 0 ]
    then
        echo "$_res"
        return 0
    elif [ "$_curl_out" -eq 51 ]
    then
        return 2
    else
        log "REST FLASHMAN" "Error connecting to server ($_curl_out)"
        return 1
    fi
}
is_mesh_slave() {
    local _mesh_mode=""
    local _mesh_master=""
    json_cleanup
    json_load_file /root/flashbox_config.json
    json_get_var _mesh_mode mesh_mode
    json_get_var _mesh_master mesh_master
    json_close_object
    [ -n "$_mesh_mode" ] && [ "$_mesh_mode" != "0" ] && [ -n "$_mesh_master" ] && echo "1" || echo "0"
}
is_authenticated() {
    local _res
    local _is_authenticated=1
    if [ "$FLM_USE_AUTH_SVADDR" == "y" ]
    then
        local _data
        _data="id=$(get_mac)&\
        organization=$FLM_CLIENT_ORG&\
        secret=$FLM_CLIENT_SECRET&\
        model=$(get_hardware_model)&\
        model_ver=$(get_hardware_version)&\
        is_mesh_active=$(is_mesh_slave)"
        _res=$(curl -s \
            -A "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)" \
            --tlsv1.2 --connect-timeout 5 --retry 1 \
            --data "$_data" \
        "https://$FLM_AUTH_SVADDR/api/device/auth")
        local _curl_res=$?
        if [ $_curl_res -eq 0 ]
        then
            json_cleanup
            json_load "$_res" 2>/dev/null
            if [ $? == 0 ]
            then
                json_get_var _is_authenticated is_authenticated
                json_close_object
            else
                log "AUTHENTICATOR" "Invalid answer from controler"
            fi
        else
            log "AUTHENTICATOR" "Error connecting to controler ($_curl_res)"
        fi
    else
        _is_authenticated=0
    fi
    return $_is_authenticated
}
is_mesh_license_available() {
    local _res
    local _slave_mac=$1
    local _is_available=1
    if [ "$FLM_USE_AUTH_SVADDR" == "y" ]
    then
        local _data
        _data="organization=$FLM_CLIENT_ORG&\
        mac=$_slave_mac&\
        secret=$FLM_CLIENT_SECRET"
        _res=$(curl -s \
            -A "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)" \
            --tlsv1.2 --connect-timeout 5 --retry 1 \
            --data "$_data" \
        "https://$FLM_AUTH_SVADDR/api/device/mesh/available")
        local _curl_res=$?
        if [ $_curl_res -eq 0 ]
        then
            json_cleanup
            json_load "$_res" 2>/dev/null
            if [ $? == 0 ]
            then
                json_get_var _is_available is_available
                json_close_object
            else
                log "AUTHENTICATOR" "Invalid answer from controler"
            fi
        else
            log "AUTHENTICATOR" "Error connecting to controler ($_curl_res)"
        fi
    else
        _is_available=0
    fi
    return $_is_available
}
