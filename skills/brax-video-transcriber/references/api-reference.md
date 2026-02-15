# API Reference

## Supadata API

### Get YouTube Transcript
```
GET https://api.supadata.ai/v1/youtube/transcript
```

**Headers:**
| Header | Value |
|--------|-------|
| x-api-key | Your Supadata API key |

**Query Parameters:**
| Parameter | Required | Description |
|-----------|----------|-------------|
| url | Yes | YouTube video URL |
| text | No | `true` for plain text, `false` for segmented (default: false) |
| lang | No | ISO 639-1 language code (e.g., `en`) |

**Responses:**
- `200` - Transcript returned successfully
- `202` - Job created for processing (poll with jobId)
- `400` - Invalid parameters
- `401` - Missing or invalid API key
- `402` - Payment required
- `404` - Video not found or no transcript available

### Poll Job Status
```
GET https://api.supadata.ai/v1/transcript/{jobId}
```

Results expire after 1 hour. Poll every 1-2 seconds.

---

## brax.guide API

### Base URL
```
https://ssihjoqwhuxcufzrjpov.supabase.co/functions/v1/api
```

### Authentication
All requests require Bearer token:
```
Authorization: Bearer brax_YourApiKeyHere
```

### Videos Collection

#### List Videos
```
GET /videos?limit=10&offset=0
```

#### Create Video
```
POST /videos
Content-Type: application/json
```

**Required fields:** `title`, `slug`

**All fields:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| title | string | Yes | Video title |
| slug | string | Yes | URL-friendly identifier |
| content | string | No | Full HTML article content |
| excerpt | string | No | Short summary (1-2 sentences) |
| thumbnail_url | string | No | Thumbnail image URL |
| video_url | string | No | Direct video URL |
| youtube_url | string | No | YouTube video URL |
| category | string | No | Category tag |
| duration | string | No | Video duration (e.g., "15:32") |
| published | boolean | No | Whether the video is published |

#### Update Video
```
PATCH /videos?id=ITEM_UUID
Content-Type: application/json
```

### Response Formats
```json
// Success (list)
{
  "data": [...],
  "count": 42,
  "limit": 50,
  "offset": 0
}

// Success (create/update)
{
  "data": {
    "id": "uuid",
    "title": "...",
    ...
  }
}

// Error
{
  "error": "Description of what went wrong"
}
```

### Pagination
Use `limit` (max 100) and `offset` query parameters.

### Rate Limits
Subject to Supabase Edge Function limits. Use reasonable delays between batch requests.

---

## Rob Braxman YouTube Channel

- **Channel:** Rob Braxman Tech
- **URL:** https://www.youtube.com/@robbraxmantech
- **Channel ID:** UCYVU6rModlGxvJbszCclGGw
- **RSS Feed:** https://www.youtube.com/feeds/videos.xml?channel_id=UCYVU6rModlGxvJbszCclGGw
- **Thumbnail pattern:** `https://img.youtube.com/vi/{VIDEO_ID}/maxresdefault.jpg`

### Common Video Categories
- Privacy
- Security
- Surveillance
- De-Googling
- VPN
- Smartphones
- Linux
- Deplatforming
- Technology
