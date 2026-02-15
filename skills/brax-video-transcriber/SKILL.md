---
name: brax-video-transcriber
description: >
  Use this skill when the user wants to transcribe a YouTube video from Rob Braxman's channel,
  create content from a YouTube transcript, publish a video to brax.guide, or mentions
  "brax", "braxman", "transcribe video", "brax.guide video", "publish video to brax.guide",
  or "youtube to brax.guide". Also triggers when the user says "transcribe latest braxman video"
  or provides a Rob Braxman YouTube URL.
version: 1.0.0
---

# Brax Video Transcriber & Publisher

Transcribe Rob Braxman YouTube videos using Supadata API and publish them to brax.guide as video entries.

## Workflow Overview

This skill performs a 5-step pipeline:

1. **Find Video** — Get the YouTube video URL (user-provided or auto-fetch latest from Rob Braxman's channel)
2. **Transcribe** — Use Supadata API to get the full transcript
3. **Research** — Search for independent sources that support and enrich the video's arguments
4. **Write** — Generate a comprehensive, research-backed article following Brax brand guidelines
5. **Publish** — Post the video entry to brax.guide via REST API (after user approval)

---

## Step 1: Get the YouTube Video

### Option A: User provides a URL
If the user provides a YouTube URL, extract the video ID and proceed.

### Option B: Auto-find latest from Rob Braxman
Rob Braxman's YouTube channel: `https://www.youtube.com/@robbraxmantech`

Use browser automation or the YouTube RSS feed to find the latest video:
```
https://www.youtube.com/feeds/videos.xml?channel_id=UCYVU6rModlGxvJbszCclGGw
```

Extract the video URL, title, thumbnail, and publish date from the feed.

---

## Step 2: Transcribe with Supadata API

### Environment Setup
Load keys from the `.env` file in the project root (`C:/claude/Youtube/.env`):
```bash
source .env
```
Or ensure the environment variables are set:
```
SUPADATA_API_KEY=your_key_here
```

### API Call
```bash
curl -s "https://api.supadata.ai/v1/youtube/transcript?url=YOUTUBE_URL&text=true" \
  -H "x-api-key: $SUPADATA_API_KEY"
```

### Parameters
- `url` - The full YouTube video URL
- `text=true` - Returns plain text transcript (recommended for article generation)
- `text=false` - Returns segmented transcript with timestamps (use if timestamps are needed)
- `lang=en` - Preferred language (optional, defaults to video's primary language)

### Handling Async Jobs (Large Videos)
If the API returns HTTP 202, it means the video is being processed:
1. Extract the `jobId` from the response
2. Poll `GET https://api.supadata.ai/v1/transcript/{jobId}` every 2 seconds
3. Continue until you get a 200 response with the transcript
4. Results expire after 1 hour

### Response Format (text=true)
```json
{
  "content": "Full transcript text here...",
  "lang": "en",
  "availableLangs": ["en"]
}
```

### Response Format (text=false / segmented)
```json
{
  "content": [
    {
      "text": "segment text",
      "offset": 0,
      "duration": 5000,
      "lang": "en"
    }
  ],
  "lang": "en"
}
```

---

## Step 3: Research the Topic

Before writing, conduct research to enrich the article with supporting evidence beyond the video.

### Research Process
1. **Identify key claims and topics** from the transcript (e.g., "client-side scanning", "Google data collection", "VPN limitations")
2. **Perform web searches** using `WebSearch` to find supporting information from **independent, credible sources**
3. **Extract relevant facts** using `WebFetch` from the search results

### Source Requirements — CRITICAL
Sources MUST come from **independent media only**. Never use Big Tech's own materials as trustworthy sources.

**Acceptable sources:**
- Security researchers and their publications (e.g., Citizen Lab, Bruce Schneier, EFF research)
- Privacy-focused NGOs (EFF, EPIC, Privacy International, Access Now, Fight for the Future)
- Independent newsletters and journalists (The Intercept, Ars Technica, Techdirt, 404 Media)
- Academic papers and university research
- Privacy advocates' blogs and statements (Rob Braxman, Louis Rossmann, Naomi Brockwell, etc.)
- Court documents and government reports
- Open-source project documentation

**NOT acceptable as trustworthy sources:**
- Apple's privacy policy when discussing Apple privacy issues
- Google's blog when discussing Google data practices
- Any Big Tech company's own statements about their own practices
- Corporate press releases or sponsored content

### Research Output
Compile a brief research document with:
- 3-8 supporting facts, statistics, or quotes from independent sources
- Source URLs for each piece of information
- How each finding supports or enriches the video's arguments

---

## Step 4: Generate Video Content

Using the transcript AND research findings, generate a comprehensive article. Follow the brand guidelines defined in `references/content_guideline.md`.

### Brand Voice Summary
- **Voice:** Confident, principled, human. We are builders and advocates.
- **Tone:** Informative, authentic, slightly conspiratorial about Big Tech's intentions. Question everything.
- **POV:** First-person plural ("we") for the company, second-person ("you") for the reader.
- **Avoid:** Clichés, passive voice, jargon, hype, buzzwords.
- **Robert Braxman** is a co-founder of Brax Technologies — reflect this when quoting or referencing him.

### Content Philosophy
This is NOT a summary. The article should:
- **Fully cover** everything discussed in the video — no key points left out
- **Enrich** with research findings that support and solidify the video's arguments
- **Question Big Tech** — be skeptical of corporate claims, entertain worst-case scenarios
- **Empower the reader** — provide actionable steps and alternatives
- **Use suggestive, not absolute language** for speculative claims (e.g., "could change everything" not "will change everything")

### Content Structure
The article must use HTML formatting for rich-text fields:

```html
<h2>Section Heading</h2>
<p>Paragraph content here with <strong>bold</strong> and <em>italic</em> emphasis.</p>

<ul>
  <li>Bullet point items for features or lists</li>
</ul>
```

**Important:** Each rich-text field uses `<h2>` headings. Plain text fields (title, excerpt) have NO headings.

### Article Structure
1. **Opening** — Hook the reader with the core problem or threat. Set the stakes.
2. **Context** — What's happening? Why does it matter? Reference the video and research.
3. **Deep Dive Sections** — Cover each major topic from the video with its own `<h2>` section. Weave in research findings, independent source quotes, and statistics.
4. **The Bigger Picture** — Connect to broader privacy/surveillance trends. Be slightly conspiratorial — what could Big Tech do with this in the future?
5. **What You Can Do** — Practical, actionable recommendations. Reference Brax products/philosophy where relevant.
6. **Sources** — List all referenced sources with links.

### Field Generation

1. **title** — Craft a compelling, suggestive title. Use "could", "may", "?" for speculative topics. Match the Brax brand voice.
   - Good: "The End of Digital Privacy? How Client-Side Scanning Could Change Everything"
   - Bad: "The End of Digital Privacy. How Client-Side Scanning Will Change Everything"
2. **slug** — URL-friendly slug from the title (lowercase, hyphens, no special chars)
3. **content** — The full article in HTML:
   - Target **1500-3000 words** (this is comprehensive coverage, not a summary)
   - Fully cover every key point from the video
   - Integrate research findings with proper attribution
   - Include source links inline (e.g., `<a href="URL">source name</a>`)
   - End with a sources section listing all references
4. **excerpt** — 1-2 sentence compelling summary (max 200 chars). Plain text, no HTML.
5. **youtube_url** — The original YouTube video URL
6. **thumbnail_url** — YouTube thumbnail: `https://img.youtube.com/vi/VIDEO_ID/maxresdefault.jpg`
7. **category** — Most appropriate: `privacy`, `security`, `technology`, `surveillance`, `deplatforming`, `smartphones`, `vpn`, `linux`, `degoogle`
8. **duration** — Video duration if available (e.g., "15:32")
9. **published** — Set to `false` (draft) by default. Let user decide to publish.

---

## Step 5: Publish to brax.guide

### API Details
- **Base URL:** `https://ssihjoqwhuxcufzrjpov.supabase.co/functions/v1/api`
- **Endpoint:** `POST /videos`
- **Auth:** Bearer token via `Authorization` header
- **Content-Type:** `application/json`

### Environment Setup
The brax.guide API key must be stored as an environment variable:
```
BRAX_GUIDE_API_KEY=your_key_here
```

### Create Video Request
```bash
curl -X POST "https://ssihjoqwhuxcufzrjpov.supabase.co/functions/v1/api/videos" \
  -H "Authorization: Bearer $BRAX_GUIDE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Video Title Here",
    "slug": "video-title-here",
    "content": "<h2>Introduction</h2><p>Article content here...</p>",
    "excerpt": "Brief summary of the video content.",
    "youtube_url": "https://www.youtube.com/watch?v=VIDEO_ID",
    "thumbnail_url": "https://img.youtube.com/vi/VIDEO_ID/maxresdefault.jpg",
    "category": "privacy",
    "duration": "15:32",
    "published": true
  }'
```

### Success Response
```json
{
  "data": {
    "id": "uuid",
    "title": "Video Title Here",
    "slug": "video-title-here",
    ...
  }
}
```

### Error Response
```json
{
  "error": "Description of what went wrong"
}
```

---

## Execution Checklist

When running this skill, follow these steps in order:

1. [ ] Determine video source (URL provided or fetch latest)
2. [ ] Load environment variables from `.env` file (`source C:/claude/Youtube/.env`)
3. [ ] Verify `SUPADATA_API_KEY` environment variable is set
4. [ ] Verify `BRAX_GUIDE_API_KEY` environment variable is set
5. [ ] Fetch the YouTube video metadata (title, thumbnail, duration)
6. [ ] Call Supadata API to get transcript
7. [ ] Handle async job polling if needed (HTTP 202)
8. [ ] **Research the topic** — search for independent sources that support the video's arguments
9. [ ] **Generate the full article** — comprehensive coverage + research enrichment, following brand guidelines
10. [ ] Show the user a preview of the generated title, excerpt, and content before publishing
11. [ ] Confirm with user before publishing to brax.guide
12. [ ] Check for duplicates on brax.guide (`GET /videos?limit=10`)
13. [ ] POST to brax.guide `/videos` endpoint
14. [ ] Verify success and return the published URL

---

## Important Notes

- **Always preview before publishing** - Show the user the generated title, excerpt, and content before POSTing to brax.guide
- **Never publish without confirmation** - Ask the user to approve the content
- **Rob Braxman's channel ID:** `UCYVU6rModlGxvJbszCclGGw`
- **Rob Braxman's channel URL:** `https://www.youtube.com/@robbraxmantech`
- **Transcript may be long** - For videos over 30 minutes, the transcript can be very large. Focus on key sections.
- **Rate limits** - brax.guide uses Supabase Edge Functions; don't spam requests
- **Check for duplicates** - Before publishing, GET `/videos?limit=5` to check if this video already exists on brax.guide
