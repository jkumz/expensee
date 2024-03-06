const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')

if (!RESEND_API_KEY) {
  throw new Error('Missing API key');
}

const handler = async (_request: Request): Promise<Response> => {
  if (_request.method !== "POST") {
    return new Response("Only POST method is accepted", { status: 405});
  }

  const requestData = await _request.json().catch(() => {
    return null;
  });

  if (!requestData || !requestData.to || !requestData.subject || !requestData.html) {
    return new Response("Missing email data in request", { status: 400 });
  }

  const { to, subject, html } = requestData;

  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${RESEND_API_KEY}`,
    },
    body: JSON.stringify({
      from: 'team@expensee.net',
      to, // Pulled from request
      subject, // Pulled from request
      html, // Pulled from request
    }),
  });

  const data = await res.json()

  return new Response(JSON.stringify(data), {
    status: 200,
    headers: {
      'Content-Type': 'application/json',
    },
  })
}

Deno.serve(handler)
