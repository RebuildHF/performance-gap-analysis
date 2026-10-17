// Stripe -> Supabase: marks a user as unlocked when a Payment Link checkout completes.
// Secrets needed: STRIPE_WEBHOOK_SECRET (whsec_...). SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are provided automatically.
import { createClient } from "npm:@supabase/supabase-js@2";

const enc = new TextEncoder();
async function verify(payload: string, header: string, secret: string): Promise<boolean> {
  const parts = Object.fromEntries(header.split(",").map((p) => p.split("=") as [string, string]));
  const t = parts["t"]; const sig = header.split(",").filter((p) => p.startsWith("v1=")).map((p) => p.slice(3));
  if (!t || !sig.length) return false;
  if (Math.abs(Date.now() / 1000 - Number(t)) > 300) return false;
  const key = await crypto.subtle.importKey("raw", enc.encode(secret), { name: "HMAC", hash: "SHA-256" }, false, ["sign"]);
  const mac = new Uint8Array(await crypto.subtle.sign("HMAC", key, enc.encode(`${t}.${payload}`)));
  const hex = Array.from(mac).map((b) => b.toString(16).padStart(2, "0")).join("");
  return sig.some((s) => s === hex);
}

Deno.serve(async (req) => {
  const secret = Deno.env.get("STRIPE_WEBHOOK_SECRET");
  if (!secret) return new Response("not configured", { status: 500 });
  const body = await req.text();
  if (!(await verify(body, req.headers.get("stripe-signature") ?? "", secret))) return new Response("bad signature", { status: 400 });
  const ev = JSON.parse(body);
  const db = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
  if (ev.type === "checkout.session.completed" || ev.type === "checkout.session.async_payment_succeeded") {
    const s = ev.data.object;
    if (s.payment_status === "paid" && s.client_reference_id) {
      const { error } = await db.from("entitlements").upsert({ user_id: s.client_reference_id, tier2: true });
      if (error) return new Response(error.message, { status: 500 });
    }
  } else if (ev.type === "charge.refunded") {
    // Refunds are handled by hand in the dashboard for now.
  }
  return new Response("ok");
});
