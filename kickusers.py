import argparse
import requests
import time

# Define the API endpoints for kicking a user and getting the room members
kick_endpoint = "https://matrix.org/_matrix/client/r0/rooms/{}/kick"
members_endpoint = "https://matrix.org/_matrix/client/r0/rooms/{}/members"

# Parse the command-line arguments
parser = argparse.ArgumentParser(description="Kick non-admin members from a Matrix room.")
parser.add_argument("access_token", help="Matrix account access token")
parser.add_argument("room_id", help="Matrix room ID")
args = parser.parse_args()

# Define headers to include the access token
headers = {
    "Authorization": f"Bearer {args.access_token}"
}

# Send a GET request to the members endpoint
response = requests.get(members_endpoint.format(args.room_id), headers=headers)

# Check if the request was successful
if response.status_code != 200:
    print("Error: Failed to get room members.")
    print(response.text)
    exit()

# Parse the response to extract the member list
member_list = response.json()["chunk"]

# Loop through the member list and kick non-admin members with a 5-second delay
for member in member_list:
    user_id = member["state_key"]
    power_level = member["power_level"]
    if power_level < 50:
        # Kick the user
        kick_data = {
            "user_id": user_id,
            "reason": "You have been kicked by the admin."
        }
        response = requests.post(kick_endpoint.format(args.room_id), headers=headers, json=kick_data)
        # Check if the request was successful
        if response.status_code != 200:
            print(f"Error: Failed to kick user {user_id}.")
            print(response.text)
        else:
            print(f"Kicked user {user_id}.")
        # Wait for 5 seconds before kicking the next user
        time.sleep(5)

