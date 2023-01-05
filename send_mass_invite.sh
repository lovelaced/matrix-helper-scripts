#!/bin/bash

# Print the usage of the script if the SERVER_URL, ADMIN_TOKEN, or ROOM_ID arguments are not provided
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 SERVER_URL ADMIN_TOKEN ROOM_ID [ROOM_ID...]"
  exit 1
fi

# Get the SERVER_URL, ADMIN_TOKEN, and ROOM_ID values from the command line arguments
SERVER_URL="$1"
ADMIN_TOKEN="$2"
shift 2
ROOM_IDS=("$@")

auth_provider_type="google"

# Set the pagination parameters
limit=10
offset=0

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

# Iterate over the mxids array
for mxid in "${mxids[@]}"; do
  # Only send an invite to human accounts which are SSO-enabled
  if [ -n "$auth_provider" ] && [[ "$auth_provider" =~ "$auth_provider_type" ]]; then
    # Send an invite for each room in the ROOM_IDS array
    for room_id in "${ROOM_IDS[@]}"; do
      # Send an invite to the user for the current room
      curl -X POST -H "Authorization: Bearer $ADMIN_TOKEN" "$SERVER_URL/_matrix/client/r0/rooms/$room_id/invite" -d "{\"user_id\": \"$mxid\"}"
    done
  fi
done

