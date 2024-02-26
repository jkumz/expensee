// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");

const handler = async (_request: Request): Promise<Response> => {
  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${RESEND_API_KEY}`,
    },
    body: JSON.stringify({
      from: 'onboarding@resend.dev',
      to: 'delivered@resend.dev',
      subject: 'hello world',
      html: '<strong>it works!</strong>',
    }),
  })

  const data = await res.json()

  return new Response(JSON.stringify(data), {
    status: 200,
    headers: {
      'Content-Type': 'application/json',
    },
  })
}

Deno.serve(handler)

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -X POST 'https://api.resend.com/emails' \
     -H 'Authorization: Bearer re_GMztJEi8_McgwfsTbN1yAhqvd4Vy12ZRy' \
     -H 'Content-Type: application/json' \
     -d $'{
  "from": "ExpenSee - TEST MAIL <onboarding@resend.dev>",
  "to": ["jkumor0698@gmail.com"],
  "subject": "test mail",
  "text": "it works!",
  "headers": {
    "X-Entity-Ref-ID": "123"
  }
}'

*/
