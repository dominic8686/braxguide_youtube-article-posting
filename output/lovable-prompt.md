# Lovable Prompt: YouTube Video Article Generator Admin UI

## What I need

Add an admin-only page at `/admin/generate-video` that lets me paste a YouTube URL and trigger an article generation pipeline via a webhook to Claude Code. The page should also show the status and history of generation jobs.

## Page Layout

### Top Section: Video Submission Form
- A text input field labeled "YouTube Video URL" with placeholder "https://www.youtube.com/watch?v=..."
- A "Generate Article" button (primary style)
- When submitted:
  1. Validate the URL is a valid YouTube URL (must contain youtube.com/watch?v= or youtu.be/)
  2. Extract the video ID from the URL
  3. Show the video thumbnail preview using `https://img.youtube.com/vi/{VIDEO_ID}/maxresdefault.jpg`
  4. Insert a new row into a `generation_jobs` table (see schema below)
  5. Call a Supabase Edge Function `generate-video-article` that sends a webhook to Claude Code
  6. Show a toast: "Article generation started. You'll see it in the videos list once complete."

### Bottom Section: Generation Jobs History
- A table showing recent generation jobs from the `generation_jobs` table
- Columns: Status (badge), YouTube URL (link), Video Title, Created At, Completed At
- Status badges: `pending` (yellow), `processing` (blue), `completed` (green), `failed` (red)
- Sort by created_at descending
- Limit to last 20 jobs

## Database: `generation_jobs` table

Create a new table called `generation_jobs` with these columns:

| Column | Type | Default | Description |
|--------|------|---------|-------------|
| id | uuid | gen_random_uuid() | Primary key |
| youtube_url | text | required | The YouTube video URL |
| video_id | text | | Extracted YouTube video ID |
| video_title | text | | Title (populated after processing) |
| status | text | 'pending' | One of: pending, processing, completed, failed |
| error_message | text | | Error details if failed |
| result_video_id | uuid | | FK to videos table once article is created |
| created_at | timestamptz | now() | When the job was created |
| updated_at | timestamptz | now() | Last status update |
| completed_at | timestamptz | | When processing finished |

Enable RLS. Only authenticated users with admin role can read/write.

## Supabase Edge Function: `generate-video-article`

Create a new Edge Function at `supabase/functions/generate-video-article/index.ts`:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const { youtube_url, job_id } = await req.json();

    if (!youtube_url || !job_id) {
      return new Response(
        JSON.stringify({ error: "youtube_url and job_id are required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Update job status to processing
    await supabaseClient
      .from("generation_jobs")
      .update({ status: "processing", updated_at: new Date().toISOString() })
      .eq("id", job_id);

    // Send webhook to Claude Code
    // The webhook URL should be stored in Supabase secrets
    const webhookUrl = Deno.env.get("CLAUDE_WEBHOOK_URL");

    if (webhookUrl) {
      const webhookPayload = {
        event: "generate_video_article",
        job_id: job_id,
        youtube_url: youtube_url,
        callback_url: `${Deno.env.get("SUPABASE_URL")}/functions/v1/api/videos`,
        api_key: Deno.env.get("BRAX_GUIDE_API_KEY"),
      };

      // Fire and forget — don't await the webhook response
      fetch(webhookUrl, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(webhookPayload),
      }).catch((err) => {
        console.error("Webhook delivery failed:", err);
      });
    }

    return new Response(
      JSON.stringify({ success: true, job_id, status: "processing" }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
```

## Edge Function: `update-job-status`

Also create a callback Edge Function that Claude Code can call to update job status once processing is complete:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer brax_")) {
      return new Response(
        JSON.stringify({ error: "Unauthorized" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const { job_id, status, video_title, result_video_id, error_message } = await req.json();

    const updateData: any = {
      status,
      updated_at: new Date().toISOString(),
    };

    if (video_title) updateData.video_title = video_title;
    if (result_video_id) updateData.result_video_id = result_video_id;
    if (error_message) updateData.error_message = error_message;
    if (status === "completed" || status === "failed") {
      updateData.completed_at = new Date().toISOString();
    }

    await supabaseClient
      .from("generation_jobs")
      .update(updateData)
      .eq("id", job_id);

    return new Response(
      JSON.stringify({ success: true }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
```

## Supabase Secrets needed

Set these secrets in the Supabase dashboard:
- `CLAUDE_WEBHOOK_URL` — The webhook endpoint where Claude Code listens (user will configure this)
- `BRAX_GUIDE_API_KEY` — The brax.guide API key to pass to Claude Code for publishing

## UI/UX Details
- Use the existing design system and component library already in the project
- The page should be accessible only to admin users (use existing auth/role checks)
- Add a link to this page in the admin sidebar/navigation if one exists
- The form should disable the submit button while a job is pending/processing
- Show a real-time status update if possible (subscribe to generation_jobs changes via Supabase Realtime)

## Important
- This is a fire-and-forget webhook pattern. The Edge Function sends the webhook and returns immediately.
- Claude Code will do the heavy lifting (transcription, research, article writing) and then:
  1. POST the completed article to `/api/videos`
  2. Call `update-job-status` to mark the job as completed with the resulting video ID
- If the webhook fails or Claude Code encounters an error, the job stays in "processing" state. Consider adding a timeout mechanism that marks jobs as "failed" if not completed within 30 minutes.
