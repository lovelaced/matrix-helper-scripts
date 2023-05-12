#!/bin/sh

# This is the host of your room
DOMAIN=matrix.org
CSAPI_URL="https://$DOMAIN/_matrix/client/r0"

# In Element, hover over the last message in the room, click the ellipses (options) and select "View Source"
OLD_ROOM_ID='!some_id'
LAST_EVENT_ID='$n032YX9C58Nsome_event'

# In Element, User Settings -> Help & About, Advanced, Access Token <click to reveal>
ACCESS_TOKEN='syt_your_access_token'

# Ask someone to verify this
ROOM_VERSION=10

NEW_ROOM_ID=`curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN"   \
     -H "Content-Type: application/json"                                \
     --data-binary "{                                                   \
                        \"room_version\":\"$ROOM_VERSION\",             \
                        \"creation_content\":{                          \
                            \"predecessor\":{                           \
                                 \"room_id\":\"$OLD_ROOM_ID\",          \
                                 \"event_id\":\"$LAST_EVENT_ID\"        \
                            }                                           \
                        }                                               \
                    }" "$CSAPI_URL/createRoom" | jq -r .room_id`
echo "New room id: $NEW_ROOM_ID"

curl -s -X PUT -H "Authorization: Bearer $ACCESS_TOKEN"                 \
     -H "Content-Type: application/json"                                \
     --data-binary "{                                                   \
                        \"replacement_room\":\"$NEW_ROOM_ID\"           \
                    }"                                                  \
     "$CSAPI_URL/rooms/$OLD_ROOM_ID/state/m.room.tombstone"           | \
     ( echo -n "Event id for room replacment: "; jq -r .event_id )
