# Youtube Article Generator

This prompt triggers a Warp agent to transcribe a YouTube video and generate a brax.guide article draft.

## Configuration

- **Environment ID**: `jWlEXG55QiNCRZgIkCUgi8` (Public clone environment)
- **API Endpoint**: `https://app.warp.dev/api/v1/agent/run`
- **Method**: `POST`
- **Headers**:
  - `Authorization`: `Bearer YOUR_WARP_API_KEY`
  - `Content-Type`: `application/json`

## Prompt Template

```json
{
  "prompt": "Process this YouTube video and create an article draft: {{YOUTUBE_URL}}. Follow the instructions in AGENTS.md in the current directory.",
  "model": "auto-genius",
  "config": {
    "environment_id": "jWlEXG55QiNCRZgIkCUgi8"
  }
}
```

## Usage

Replace `{{YOUTUBE_URL}}` with the actual YouTube video URL you want to process.
The agent will:
1. Transcribe the video using Supadata API
2. Research the topic
3. Generate a draft article
4. Publish it as a draft to brax.guide
