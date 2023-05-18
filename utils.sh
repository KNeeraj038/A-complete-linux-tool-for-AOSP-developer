#!/bin/bash


nrj_connect_to_vpn(){
    # Set the required inputs
    local username="kneeraj"
    local password="Nrj9801223938NN"
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