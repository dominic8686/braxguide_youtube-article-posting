# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a Warp skill that transcribes Rob Braxman YouTube videos and publishes them as articles to brax.guide. The skill is defined in `skills/brax-video-transcriber/SKILL.md`.

## Architecture

```
youtube article posting/
├── skills/brax-video-transcriber/
│   ├── SKILL.md              # Main skill definition (5-step pipeline)
│   ├── references/
│   │   ├── api-reference.md  # Supadata & brax.guide API docs
│   │   └── content_guideline.md  # Brax brand voice & writing style
│   └── scripts/              # Bash helper scripts (fetch, transcribe, publish)
├── output/                   # Generated content drafts
└── .env                      # API keys (SUPADATA_API_KEY, BRAX_GUIDE_API_KEY)
```

## Key Workflow Steps

1. **Find Video** — Get YouTube URL or auto-fetch latest from Rob Braxman's channel via RSS
2. **Transcribe** — Use Supadata API (`api.supadata.ai/v1/youtube/transcript`)
3. **Research** — Find independent sources supporting the video's claims
4. **Write** — Generate HTML article following brand guidelines (1500-3000 words)
5. **Publish** — POST to brax.guide API (requires user approval)

## External APIs

| API | Base URL | Auth Header |
|-----|----------|-------------|
| Supadata | `api.supadata.ai/v1` | `x-api-key: $SUPADATA_API_KEY` |
| brax.guide | `ssihjoqwhuxcufzrjpov.supabase.co/functions/v1/api` | `Authorization: Bearer $BRAX_GUIDE_API_KEY` |

## Rob Braxman Channel

- **Channel ID:** `UCYVU6rModlGxvJbszCclGGw`
- **RSS Feed:** `https://www.youtube.com/feeds/videos.xml?channel_id=UCYVU6rModlGxvJbszCclGGw`
- **Thumbnail pattern:** `https://img.youtube.com/vi/{VIDEO_ID}/maxresdefault.jpg`

## Content Requirements

- **Voice:** Confident, principled, human — Brax is both a product maker and movement builder
- **Tone:** Informative, authentic, skeptical of Big Tech claims
- **POV:** First-person plural ("we") for company, second-person ("you") for reader
- **Sources:** Must use independent media only (EFF, Ars Technica, researchers) — never cite Big Tech's own statements about themselves
- **Robert Braxman is a co-founder** — reference him appropriately when quoting

## Article HTML Structure

Articles use `<h2>` for section headings, `<p>` for paragraphs, `<ul><li>` for lists. Fields like title/excerpt are plain text without HTML.

## Critical Workflow Rules

- Always preview generated content before publishing
- Never publish without explicit user confirmation
- Check for duplicates on brax.guide (`GET /videos?limit=10`) before creating
- Handle async Supadata jobs (HTTP 202) by polling the job endpoint
- Use suggestive language ("could", "may") for speculative claims
