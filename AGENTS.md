# AGENTS.md

This file provides complete guidance for transcribing Rob Braxman YouTube videos and publishing them as articles to brax.guide.

## Project Overview

This workflow transcribes Rob Braxman YouTube videos using Supadata API and publishes them as comprehensive articles to brax.guide. The YouTube URL is provided via Oz API as input when spawning the agent.

## 5-Step Workflow

### Step 1: Get YouTube URL
The YouTube URL is provided as input via the Oz API prompt. Extract the video ID from the URL for use in subsequent steps.

### Step 2: Transcribe with Supadata API

**IMPORTANT: You MUST use the Supadata API for transcription. Do NOT use yt-dlp, youtube-dl, whisper, or any other tool. The Supadata API is already set up and working.**

**API Endpoint:**
```bash
curl -s "https://api.supadata.ai/v1/youtube/transcript?url=YOUTUBE_URL&text=true" \
  -H "x-api-key: $SUPADATA_API_KEY"
```

**Parameters:**
- `url` - Full YouTube video URL
- `text=true` - Returns plain text transcript (recommended)
- `lang=en` - Language (optional)

**Async Jobs:** If API returns HTTP 202, poll `GET https://api.supadata.ai/v1/transcript/{jobId}` every 2 seconds until 200.

**Helper Script:** `skills/brax-video-transcriber/scripts/transcribe.sh <youtube_url>`

### Step 3: Research the Topic

Conduct research to enrich the article beyond the video transcript.

**Research Process:**
1. Identify key claims from transcript
2. Perform web searches for supporting information
3. Extract 3-8 relevant facts, statistics, or quotes

**Acceptable Sources:**
- Security researchers (Citizen Lab, Bruce Schneier, EFF)
- Privacy NGOs (EFF, EPIC, Privacy International, Access Now)
- Independent media (The Intercept, Ars Technica, Techdirt, 404 Media)
- Academic papers and research
- Privacy advocates (Rob Braxman, Louis Rossmann, Naomi Brockwell)
- Court documents, government reports

**NOT Acceptable:**
- Big Tech's own statements about themselves
- Corporate press releases or sponsored content

### Step 4: Generate Article

Create a comprehensive 1500-3000 word HTML article. This is NOT a summary—fully cover everything in the video plus research findings.

**Article Structure:**
1. **Opening** — Hook with core problem/threat
2. **Context** — What's happening and why it matters
3. **Deep Dive** — Cover each major topic with `<h2>` sections, weave in research
4. **Bigger Picture** — Connect to broader privacy/surveillance trends
5. **What You Can Do** — Actionable recommendations
6. **Sources** — List all references with links

**HTML Formatting:**
```html
<h2>Section Heading</h2>
<p>Paragraph with <strong>bold</strong> and <em>italic</em> emphasis.</p>
<ul>
  <li>List items</li>
</ul>
```

**Required Fields:**
- `title` - Compelling, suggestive (use "could", "may", "?")
- `slug` - URL-friendly (lowercase, hyphens)
- `content` - Full HTML article (1500-3000 words)
- `excerpt` - 1-2 sentences (max 200 chars, plain text)
- `youtube_url` - Original video URL
- `thumbnail_url` - `https://img.youtube.com/vi/{VIDEO_ID}/maxresdefault.jpg`
- `category` - One of: privacy, security, technology, surveillance, deplatforming, smartphones, vpn, linux, degoogle
- `duration` - Video duration (e.g., "15:32")
- `published` - Set to `false` (draft mode)

### Step 5: Publish Draft Automatically

Save the generated article to `output/` directory as JSON, then automatically publish it as a draft to brax.guide.

**Before publishing:**
1. Check for duplicates: `GET /videos?limit=10` - skip if video already exists
2. Ensure `published` is set to `false` (draft mode)

**Publish command:**
```bash
curl -X POST "https://ssihjoqwhuxcufzrjpov.supabase.co/functions/v1/api/videos" \
  -H "Authorization: Bearer $BRAX_GUIDE_API_KEY" \
  -H "Content-Type: application/json" \
  -d @article.json
```

Confirm the draft was created successfully and report the result.

---

## Brand Guidelines

### About Brax Technologies
Brax Technologies builds privacy-first products that challenge Big Tech's control. We give users freedom through open, accessible technology. Robert Braxman (Rob Braxman Tech YouTube channel) is a co-founder.

### Voice
- **Confident, principled, human** - We're builders and advocates
- **Transparent** - Tell it as it is, don't hide tradeoffs
- **Empowering** - Help users take control
- **Mission-driven** - Everything connects to making privacy accessible

### Tone
- **Informative and authentic** - Precision over hype
- **Skeptical of Big Tech** - Question their claims and intentions
- **Slightly conspiratorial** - Entertain worst-case scenarios about Big Tech
- **Avoid:** Clichés, passive voice, jargon, buzzwords, hype

### Point of View
- Use "we" for the company
- Use "you" for the reader

### Critical Rules
- Use suggestive language for speculation ("could", "may") not absolutes ("will")
- Always cite sources
- Question Big Tech statements even if substantiated
- Robert Braxman is a co-founder - reflect this when quoting him

---

## API Reference

### Supadata API
**Base:** `https://api.supadata.ai/v1`  
**Auth:** `x-api-key: $SUPADATA_API_KEY`

**Get Transcript:**
```
GET /youtube/transcript?url={YOUTUBE_URL}&text=true
```

**Responses:**
- 200 - Success
- 202 - Processing (poll with jobId)
- 400 - Invalid parameters
- 401 - Invalid API key
- 404 - Video not found

### brax.guide API
**Base:** `https://ssihjoqwhuxcufzrjpov.supabase.co/functions/v1/api`  
**Auth:** `Authorization: Bearer $BRAX_GUIDE_API_KEY`

**List Videos:**
```
GET /videos?limit=10&offset=0
```

**Create Video:**
```
POST /videos
Content-Type: application/json
```

**Update Video:**
```
PATCH /videos?id={UUID}
```

### Rob Braxman Channel
- **Channel:** Rob Braxman Tech
- **URL:** https://www.youtube.com/@robbraxmantech
- **Channel ID:** UCYVU6rModlGxvJbszCclGGw
- **RSS:** https://www.youtube.com/feeds/videos.xml?channel_id=UCYVU6rModlGxvJbszCclGGw

---

## Environment & Secrets

In Oz cloud environment, these secrets are automatically available:
- `SUPADATA_API_KEY` - For transcript API
- `BRAX_GUIDE_API_KEY` - For publishing

Helper scripts in `skills/brax-video-transcriber/scripts/` automatically load `.env` if running locally.

---

## Execution Checklist

1. ✓ Extract YouTube URL from input prompt
2. ✓ Verify secrets are available
3. ✓ Fetch video metadata (title, thumbnail, duration)
4. ✓ Call Supadata API for transcript (handle async if needed)
5. ✓ Research topic with independent sources
6. ✓ Generate comprehensive article following brand guidelines
7. ✓ Save draft to output/ directory
8. ✓ Check for duplicates before publishing
9. ✓ POST to brax.guide API as draft (published: false)
10. ✓ Confirm draft creation and report result
