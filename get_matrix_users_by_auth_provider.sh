#!/bin/bash

# Print the usage of the script if the SERVER_URL or ADMIN_TOKEN arguments are not provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 SERVER_URL ADMIN_TOKEN"
  exit 1
fi

# Get the SERVER_URL and ADMIN_TOKEN from the command line arguments
SERVER_URL="$1"
ADMIN_TOKEN="$2"

# Set the pagination parameters
limit=100
offset=0

# define auth provider type to exclude
auth_provider_type="google"

# Initialize an empty array to store the mxids
mxids=()

# Fetch all mxids from the matrix-synapse server
while true; do
  # Get a list of users from the matrix-synapse server, using pagination
  response=$(curl -s -H "Authorization: Bearer $ADMIN_TOKEN" "$SERVER_URL/_synapse/admin/v2/users?from=$offset&limit=$limit&guests=false" | jq '.')

  # Extract the mxid values from the user objects as an array
  mxids_temp=$(echo "$response" | jq -r '.users[].name')

  # Parse the mxids_temp array and extract the individual mxid values
  while read -r mxid; do
    # Append the mxid value to the mxids array
    mxids+=("$mxid")
  done <<< "$mxids_temp"
  # Check if there are more users to fetch
  total=$(echo "$response" | jq '.total')
  if [ "$offset" -ge "$total" ]; then
    # All users have been fetched, exit the loop
    break
  fi

  # Increment the offset for the next iteration
  offset=$((offset + limit))
done

echo "The following users do not have the $auth_provider_type auth_provider configured:"

# Iterate over the mxids array
for mxid in "${mxids[@]}"; do
  # Send a GET request to the /_synapse/admin/v2/users/<mxid> endpoint
  response=$(curl -s -H "Authorization: Bearer $ADMIN_TOKEN" "$SERVER_URL/_synapse/admin/v2/users/$mxid")
  # Parse the response and extract the external_ids and auth_provider values
  auth_provider=$(echo "$response" | jq -r '.external_ids[].auth_provider')
    # Print the mxid if the auth_provider value is null or does not contain the string 'google'
   if [ -z "$auth_provider" ] || ! [[ "$auth_provider" =~ "$auth_provider_type" ]]; then
     echo "$mxid"
   fi

done
