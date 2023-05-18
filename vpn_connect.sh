#!/bin/bash

# Set the required inputs
username="kneeraj"
password="Nrj9801223938NN"
domain="LocalDomain"
server="14.97.141.34:4433"

# Run the NetExtender executable with the provided inputs
netExtender --username "$username" --password "$password" -d "$domain" "$server"
