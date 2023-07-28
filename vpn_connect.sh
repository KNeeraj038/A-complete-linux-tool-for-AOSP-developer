#!/bin/bash

# Set the required inputs
username="<username"
password="<pwd>"
domain="LocalDomain"
server="14.97.141.34:4433"

# Run the NetExtender executable with the provided inputs
netExtender --username "$username" --password "$password" -d "$domain" "$server"
