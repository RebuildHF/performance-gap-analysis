# Performance Gap Analysis

A single-file web app (`index.html`, no build step) that turns subjective 0 to 10 movement ratings into a weekly breakdown of priorities (practice, strengthen, condition) and how often each needs a turn.

Currently covers the Rx and Scaled mixed-modal versions. A weightlifting version is planned.

## Tiers
- **Tier 1 (free):** summary of the ratings, a basic focus indicator (skill, strength and mobility, conditioning) and the score key.
- **Tier 2 (paid, not yet enforced):** full weekly plan, strength ratios, weightlifting / gymnastics / metabolic conditioning summaries and metcon benchmark levels. The lock in this version is a client-side preview only.

## Run it
Open `index.html` in a browser. Drafts are kept in the browser's localStorage only.

## Next steps
- Supabase: athlete logins, saved assessments, and a server-side flag for Tier 2.
- Hosting from this repo (for example Netlify, Vercel or Cloudflare Pages).
- Payments.
