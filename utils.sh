#!/bin/bash


nrj_connect_to_vpn(){
    # Set the required inputs
    local username="<user_name>"
    local password="<pwd>"
    local domain="LocalDomain"
    local server="14.97.141.34:4433"

    # Run the NetExtender executable with the provided inputs
    netExtender --username "$username" --password "$password" -d "$domain" "$server"
}


nrj_start_log(){
    if [ -z "$1" ]
    then
        filename="logcat"
    else
        filename="$1"
    fi

    bash android_log.sh "$filename"
}

va_agp() {

   adb shell getprop
}

va_asp() {

  local prop=$1
  local value=$2
  
  adb root && adb shell setprop $prop $value
}

va_update() {
    if [ "$1" == "--help" ] ; then
        echo "\nUsage: iw_perform_ota [OPTIONS/PATH]
        \nPushes OTA to cache partition and installs update.
        \nTHIS REQUIRES ROOT ADB CONNECTION TO STB
        \nExample: iw_perform_ota $OUT/OTA*.zip
        \nOptions:
        \n\tPATH   : path to the OTA.zip file
        \n\t--help : prints this description"
        return
    fi

    if [ "$#" -ne 1 ]; then
        echo "Illegal number of parameters"
        echo "Usage: iw_perform_ota [OTA IMAGE]\n"
        return
    fi

    if ! [ -x "$(command -v adb)" ]; then
        echo 'adb is not installed.'
        return
    fi

    if [ $(adb devices | wc -l) -lt 3 ]; then
        echo 'Device not connected'
        return
    fi

   perform_non_ab_update $1
}

perform_non_ab_update() {

    local local_path=$1
    local remote_path="/cache/recovery/update.zip"

    adb root > /dev/null && adb wait-for-device

    adb shell 'mkdir -p /cache/recovery'
    adb shell "echo 'boot-recovery ' > /cache/recovery/command"
    adb shell "echo '--update_package=$remote_path' >> /cache/recovery/command"

    echo "Uploading image to '$remote_path' ..."
    adb push $local_path $remote_path

    echo "Rebooting ..."
    adb reboot recovery &
}
