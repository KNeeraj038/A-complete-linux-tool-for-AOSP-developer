#!/bin/bash

ini_file="config.ini"

# Function to read values from the INI file
function read_ini {
    local section="$1"
    local key="$2"

    # Use awk to read the value from the INI file
    awk -F= -v section="$section" -v key="$key" '
        $1 == "[" section "]" {
            in_section = 1
            next
        }
        in_section && $1 == key {
            print $2
            exit
        }
        in_section && /^\[.*\]/ {
            # If we reach the next section, stop looking
            exit
        }
    ' "$ini_file"
}

nrj_connect_to_vpn(){

   # Read the username and password from the INI file
    local username=$(read_ini "Credentials" "username")
    local password=$(read_ini "Credentials" "password")
    local domain="LocalDomain"
    local server="14.97.141.34:4433"

    echo "Username: $username"
    echo "Password: $password"
    echo "Domain: $domain"
    echo "Server: $server"

    # Run the NetExtender executable with the provided inputs
    netExtender --username $username --password $password -d $domain $server
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

va_ad() {
   if [ "$#" -ne 1 ]; then
       adb shell dumpsys
   fi

   if [ "$1" == "-l" ]
   then
         adb shell dumpsys -l
   else
         adb shell dumpsys $1
   fi
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

# Print all available commands and their working
va_help() {
    echo -e "\nAvailable commands:\n"
    echo "nrj_connect_to_vpn : Connect to VPN using NetExtender"
    echo "nrj_start_log      : Start Android logcat"
    echo "va_agp             : Get Android device properties using adb shell getprop"
    echo "va_asp             : Set Android device property using adb shell setprop"
    echo "va_ad              : Get Android dumpsys information"
    echo "va_update          : Pushes OTA to cache partition and installs the update (Root ADB connection required)"
    echo "va_help            : Print this help information"
}
