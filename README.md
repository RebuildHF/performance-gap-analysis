# Performance Gap Analysis

A single-file web app (`index.html`, no build step) that turns subjective 0 to 10 movement ratings into a weekly breakdown of priorities (practice, train, condition) and how often each needs a turn.

Currently covers the Rx and Scaled mixed-modal versions. A weightlifting version is planned.

## Tiers
- **Tier 1 (free, no login):** summary of the ratings, a basic focus indicator (skill, strength and mobility, conditioning) and the score key.
- **Tier 2 (login plus unlock):** full weekly plan, 1RMs and strength ratios, weightlifting / gymnastics / metabolic conditioning summaries, metcon benchmark levels, and saved assessments. 1RM entry only appears once Tier 2 is unlocked.

## Run it
Open `index.html` in a browser (or host the file on any static host). Drafts are also kept in the browser's localStorage.

## Supabase
Project: "Performance Gap Analysis" (ap-southeast-2). Schema is in `supabase/migrations/`.
- Athletes sign in with email and password (magic link is planned once payments are set up).
- `assessments`: each athlete's saved assessments, readable and editable only by that athlete (row level security).
- `entitlements`: whether Tier 2 is unlocked for a login. Athletes can read their own row but cannot change it. To unlock someone for now, set `tier2` to true for their user in the Supabase dashboard (Table editor, `entitlements`).
- The URL and publishable key in `index.html` are safe to be public. Never put the service role key in the app.

Note: the plan is computed in the browser, so the unlock flag controls what the app shows but is not a hard paywall. A real paywall needs server-side plan generation.

## Next steps
- Configure Supabase Auth: site URL and redirect URLs once hosted, and a custom email sender.
- Hosting from this repo (for example Netlify, Vercel or Cloudflare Pages).
- Payments, then magic-link emails after purchase.
