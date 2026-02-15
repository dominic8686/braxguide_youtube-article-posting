# Oz Agent Prompt Template

Use this prompt when spawning an Oz agent to transcribe and create articles from YouTube videos:

```
Read and follow the workflow defined in skills/brax-video-transcriber/SKILL.md.

Transcribe this YouTube video and create a comprehensive article: {YOUTUBE_URL}

Requirements:
1. Follow the 5-step workflow in SKILL.md
2. Use the brand guidelines from skills/brax-video-transcriber/references/content_guideline.md
3. Use the API reference from skills/brax-video-transcriber/references/api-reference.md
4. Save the draft article to output/ directory
5. DO NOT publish without explicit approval

The SUPADATA_API_KEY and BRAX_GUIDE_API_KEY secrets are available as environment variables.
```

## Example Command

```bash
oz agent run-cloud --environment EhL4J31sZhwdiSJjyQCpkp --prompt "Read and follow the workflow defined in skills/brax-video-transcriber/SKILL.md. Transcribe this YouTube video and create a comprehensive article: https://www.youtube.com/watch?v=VIDEO_ID. Use the brand guidelines from skills/brax-video-transcriber/references/content_guideline.md. Save the draft to output/ directory. DO NOT publish without approval."
```
