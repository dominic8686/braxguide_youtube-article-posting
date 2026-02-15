#!/bin/bash
# Brax Video Transcriber - Helper Script
# Transcribes a YouTube video using Supadata API
#
# Usage: ./transcribe.sh <youtube_url>
# Requires: SUPADATA_API_KEY environment variable

set -euo pipefail

# Load .env if it exists (for local development)
if [ -f "$(dirname "$0")/../../../.env" ]; then
  source "$(dirname "$0")/../../../.env"
fi

YOUTUBE_URL="${1:-}"

if [ -z "$YOUTUBE_URL" ]; then
  echo "Usage: ./transcribe.sh <youtube_url>"
  echo "  e.g., ./transcribe.sh https://www.youtube.com/watch?v=dQw4w9WgXcQ"
  exit 1
fi

if [ -z "${SUPADATA_API_KEY:-}" ]; then
  echo "Error: SUPADATA_API_KEY environment variable not set"
  echo "  export SUPADATA_API_KEY=your_key_here"
  exit 1
fi

echo "Fetching transcript for: $YOUTUBE_URL"
echo "---"

# Make the API request
RESPONSE=$(curl -s -w "\n%{http_code}" \
  "https://api.supadata.ai/v1/youtube/transcript?url=${YOUTUBE_URL}&text=true" \
  -H "x-api-key: ${SUPADATA_API_KEY}")

# Extract HTTP status code (last line) and body (everything else)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
  echo "Transcript retrieved successfully!"
  echo "---"
  echo "$BODY"
elif [ "$HTTP_CODE" = "202" ]; then
  # Async job - need to poll
  JOB_ID=$(echo "$BODY" | grep -o '"jobId":"[^"]*"' | cut -d'"' -f4)
  echo "Video is being processed. Job ID: $JOB_ID"
  echo "Polling for results..."

  while true; do
    sleep 2
    POLL_RESPONSE=$(curl -s -w "\n%{http_code}" \
      "https://api.supadata.ai/v1/transcript/${JOB_ID}" \
      -H "x-api-key: ${SUPADATA_API_KEY}")

    POLL_CODE=$(echo "$POLL_RESPONSE" | tail -n1)
    POLL_BODY=$(echo "$POLL_RESPONSE" | sed '$d')

    if [ "$POLL_CODE" = "200" ]; then
      echo "Transcript ready!"
      echo "---"
      echo "$POLL_BODY"
      break
    elif [ "$POLL_CODE" = "202" ]; then
      echo "  Still processing..."
    else
      echo "Error polling job: HTTP $POLL_CODE"
      echo "$POLL_BODY"
      exit 1
    fi
  done
else
  echo "Error: HTTP $HTTP_CODE"
  echo "$BODY"
  exit 1
fi
