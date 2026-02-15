#!/bin/bash
# Fetch Latest Rob Braxman Video - Helper Script
# Gets the latest video from Rob Braxman's YouTube channel via RSS feed
#
# Usage: ./fetch-latest.sh

set -euo pipefail

CHANNEL_ID="UCYVU6rModlGxvJbszCclGGw"
RSS_URL="https://www.youtube.com/feeds/videos.xml?channel_id=${CHANNEL_ID}"

echo "Fetching latest video from Rob Braxman Tech..."
echo "---"

# Fetch the RSS feed
FEED=$(curl -s "$RSS_URL")

# Extract the first video entry
TITLE=$(echo "$FEED" | grep -m1 '<title>' | sed -n '2p' | sed 's/.*<title>//;s/<\/title>.*//' || echo "$FEED" | grep -o '<title>[^<]*</title>' | sed -n '2p' | sed 's/<[^>]*>//g')
VIDEO_URL=$(echo "$FEED" | grep -m1 '<link rel="alternate" href="https://www.youtube.com/watch' | grep -o 'href="[^"]*"' | sed 's/href="//;s/"//')
VIDEO_ID=$(echo "$VIDEO_URL" | grep -o 'v=[^&]*' | sed 's/v=//')
PUBLISHED=$(echo "$FEED" | grep -m1 '<published>' | sed 's/.*<published>//;s/<\/published>.*//')
THUMBNAIL="https://img.youtube.com/vi/${VIDEO_ID}/maxresdefault.jpg"

echo "Title:     $TITLE"
echo "URL:       $VIDEO_URL"
echo "Video ID:  $VIDEO_ID"
echo "Published: $PUBLISHED"
echo "Thumbnail: $THUMBNAIL"
