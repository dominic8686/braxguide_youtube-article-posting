#!/bin/bash
# Brax Video Publisher - Helper Script
# Publishes a video entry to brax.guide
#
# Usage: ./publish.sh <json_file>
# Requires: BRAX_GUIDE_API_KEY environment variable
#
# The JSON file should contain the video data:
# {
#   "title": "...",
#   "slug": "...",
#   "content": "...",
#   "excerpt": "...",
#   "youtube_url": "...",
#   "thumbnail_url": "...",
#   "category": "...",
#   "duration": "...",
#   "published": true
# }

set -euo pipefail

JSON_FILE="${1:-}"

if [ -z "$JSON_FILE" ]; then
  echo "Usage: ./publish.sh <json_file>"
  echo "  e.g., ./publish.sh video-data.json"
  exit 1
fi

if [ ! -f "$JSON_FILE" ]; then
  echo "Error: File not found: $JSON_FILE"
  exit 1
fi

if [ -z "${BRAX_GUIDE_API_KEY:-}" ]; then
  echo "Error: BRAX_GUIDE_API_KEY environment variable not set"
  echo "  export BRAX_GUIDE_API_KEY=your_key_here"
  exit 1
fi

echo "Publishing video to brax.guide..."
echo "---"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "https://brax.guide/api/videos" \
  -H "Authorization: Bearer ${BRAX_GUIDE_API_KEY}" \
  -H "Content-Type: application/json" \
  -d @"$JSON_FILE")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
  echo "Video published successfully!"
  echo "---"
  echo "$BODY"
else
  echo "Error: HTTP $HTTP_CODE"
  echo "$BODY"
  exit 1
fi
