#!/bin/bash

if [ $# -ne 3 ]; then
	echo "Usage: $0 <ip> <username> <password>"
	exit 1
fi

ILO_ADDRESS="https://$1"
ILO_USERNAME=$2
ILO_PASSWORD=$3

# The API endpoint to retrieve the server power status
POWER_ENDPOINT_TEST="${ILO_ADDRESS}/redfish/v1/Systems/1/"

# Send the API request to get the server power status
RESPONSE=$(curl -k -u "${ILO_USERNAME}:${ILO_PASSWORD}" -H "Content-Type: application/json" "${POWER_ENDPOINT_TEST}")

# Extract the power state from the response using jq (JSON processor)
POWER_STATE=$(echo "${RESPONSE}" | jq -r '.PowerState')

# Check the power state
if [ "${POWER_STATE}" = "On" ]; then
    echo "Server is powered ON."
elif [ "${POWER_STATE}" = "Off" ]; then

    # The API endpoint to set the server power state
    POWER_ENDPOINT="${ILO_ADDRESS}/redfish/v1/Systems/1/Actions/ComputerSystem.Reset/"

    # The payload to power on the server
    PAYLOAD='{"Action": "Reset", "ResetType": "On"}'

    # Send the API request to power on the server
    curl -k -X POST -u "${ILO_USERNAME}:${ILO_PASSWORD}" -H "Content-Type: application/json" -d "${PAYLOAD}" "${POWER_ENDPOINT}"

    # Check the HTTP response code to see if the request was successful
    if [ $? -eq 0 ]; then
        echo "Server power-on command sent successfully."
    else
        echo "Error sending power-on command."
    fi
else
    echo "Unable to determine server power status."
fi
