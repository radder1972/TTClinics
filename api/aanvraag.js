// Vercel Serverless Function: api/aanvraag.js
// TT Clinics - Automatische E-mail Notificatie bij Nieuwe Aanvragen & Offertes

export default async function handler(req, res) {
  // CORS Headers
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
  );

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed (gebruik POST)' });
  }

  try {
    const body = typeof req.body === 'string' ? JSON.parse(req.body) : (req.body || {});
    
    const naam = (body.naam || body.name || '').trim();
    const telefoon = (body.telefoon || body.phone || '').trim();
    const email = (body.email || '').trim();
    const bedrijf = (body.bedrijf || body.company || '').trim();
    const clinic = (body.clinic || body.interesse || 'Company Battle').trim();
    const personen = (body.personen || body.aantal || '').trim();
    const datum = (body.datum || body.date || '').trim();
    const locatie = (body.locatie || 'Weesp (The Victory)').trim();
    const opmerkingen = (body.opmerkingen || body.bericht || body.message || '').trim();
    const bron = (body.bron || body.source || 'Website Contactformulier').trim();

    if (!naam) {
      return res.status(400).json({ error: 'Vul alsjeblieft een naam in.' });
    }

    if (!email && !telefoon) {
      return res.status(400).json({ error: 'Vul minimaal een telefoonnummer of e-mailadres in zodat we contact kunnen opnemen.' });
    }

    // Clinic label formatting
    const clinicLabels = {
      'battle': 'Company Battle (Meest gekozen · tot 12 pers · 2,5 uur · €745,-)',
      'blacklight': 'Glow-in-the-Dark / Blacklight Team Clinic (The Victory Weesp)',
      'kickoff': 'Team Kick-off (tot 12 pers · 1,5 uur · €395,-)',
      'toernooi-op-maat': 'Eigen Toernooi op Maat (tot 8 pers of grote groepen)',
      'woensdagochtend': 'Woensdagochtend Tafeltennis (The Victory Weesp)',
      'thevictory': 'Clinic bij TTV The Victory Weesp',
      'overig': 'Overig / Maatwerk voorstel'
    };
    const clinicLabel = clinicLabels[clinic] || clinic;

    // Tijdstip in Europe/Amsterdam (Nederlandse tijd)
    const now = new Date();
    const formattedTimestamp = now.toLocaleString('nl-NL', {
      timeZone: 'Europe/Amsterdam',
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    });

    // 1. Onderwerp (exact zoals in het voorbeeld)
    const subject = `🚨 NIEUWE AANVRAAG: ${naam}${telefoon ? ' (' + telefoon + ')' : ''} - TT Clinics`;

    // 2. Plain Text versie voor snelle previews in notificaties
    const plainText = `Er is zojuist een nieuwe clinic-aanvraag/terugbelverzoek binnengekomen via ttclinics.nl:

Naam: ${naam}
${bedrijf ? 'Bedrijf / Team: ' + bedrijf + '\n' : ''}Telefoon: ${telefoon || 'Niet opgegeven'}
E-mail: ${email || 'Niet opgegeven'}
Type Clinic: ${clinicLabel}
${personen ? 'Aantal personen: ' + personen + '\n' : ''}${datum ? 'Voorkeursdatum: ' + datum + '\n' : ''}${locatie ? 'Locatie: ' + locatie + '\n' : ''}${opmerkingen ? 'Opmerkingen: ' + opmerkingen + '\n' : ''}Bron: ${bron}
Tijdstip: ${formattedTimestamp}

Graag z.s.m. bellen om de afspraak te bevestigen!`;

    // 3. Opgemaakte HTML E-mail in TT Clinics huisstijl
    const htmlMsg = `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>${escapeHtml(subject)}</title>
</head>
<body style="margin:0; padding:24px 10px; background-color:#f3f4f6; font-family:-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; color:#1f2937;">
  <table role="presentation" width="100%" border="0" cellspacing="0" cellpadding="0" style="max-width:620px; margin:0 auto; background-color:#ffffff; border-radius:18px; overflow:hidden; box-shadow:0 8px 30px rgba(0,0,0,0.08); border:1px solid #e5e7eb;">
    
    <!-- HEADER MET TT CLINICS LOGO & ORANJE ACCENT -->
    <tr>
      <td style="padding:26px 30px; background-color:#1e293b; border-bottom:4px solid #FF6B00; text-align:left;">
        <table role="presentation" width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td style="vertical-align:middle;">
              <div style="font-size:24px; font-weight:900; font-style:italic; color:#ffffff; letter-spacing:-0.5px;">
                🏓 TT <span style="color:#FF6B00;">CLINICS</span>
              </div>
              <div style="font-size:12px; color:#94a3b8; font-weight:600; text-transform:uppercase; letter-spacing:1px; margin-top:2px;">
                Tafeltennis Clinics · The Victory Weesp
              </div>
            </td>
            <td style="vertical-align:middle; text-align:right;">
              <span style="display:inline-block; background-color:#FF6B00; color:#ffffff; font-weight:800; font-size:11px; padding:6px 14px; border-radius:20px; text-transform:uppercase; letter-spacing:0.8px;">
                🚨 Nieuwe Aanvraag
              </span>
            </td>
          </tr>
        </table>
      </td>
    </tr>

    <!-- HOOFD BANNER CARD -->
    <tr>
      <td style="padding:28px 30px 10px 30px;">
        <table role="presentation" width="100%" border="0" cellspacing="0" cellpadding="0" style="background-color:#fff7ed; border:2px solid #ffedd5; border-radius:14px; padding:18px 20px;">
          <tr>
            <td style="vertical-align:middle;">
              <div style="font-size:12px; font-weight:800; text-transform:uppercase; letter-spacing:0.8px; color:#ea580c;">
                Nieuw Clinic / Offerte Verzoek
              </div>
              <div style="font-size:22px; font-weight:900; color:#111827; margin-top:4px;">
                ${escapeHtml(naam)} ${bedrijf ? '<span style="font-size:16px; font-weight:600; color:#6b7280;">(' + escapeHtml(bedrijf) + ')</span>' : ''}
              </div>
            </td>
          </tr>
        </table>
      </td>
    </tr>

    <!-- DETAILS LIJST -->
    <tr>
      <td style="padding:15px 30px 25px 30px;">
        <table role="presentation" width="100%" border="0" cellspacing="0" cellpadding="0" style="font-size:15px; line-height:1.6;">
          
          <!-- TELEFOON -->
          <tr>
            <td style="padding:10px 0 10px 0; vertical-align:middle; color:#64748b; width:140px; font-weight:600;">Telefoon:</td>
            <td style="padding:10px 0; vertical-align:middle; font-weight:800; font-size:17px; color:#0f172a;">
              ${telefoon ? `<a href="tel:${escapeHtml(telefoon.replace(/[^0-9+]/g, ''))}" style="color:#FF6B00; text-decoration:none;">${escapeHtml(telefoon)}</a>` : '<span style="color:#94a3b8; font-weight:normal;">Niet opgegeven</span>'}
            </td>
          </tr>

          <!-- E-MAIL -->
          <tr>
            <td style="padding:10px 0; vertical-align:middle; color:#64748b; font-weight:600; border-top:1px solid #f1f5f9;">E-mail:</td>
            <td style="padding:10px 0; vertical-align:middle; font-weight:700; color:#0f172a; border-top:1px solid #f1f5f9;">
              ${email ? `<a href="mailto:${escapeHtml(email)}" style="color:#2563eb; text-decoration:none;">${escapeHtml(email)}</a>` : '<span style="color:#94a3b8; font-weight:normal;">Niet opgegeven</span>'}
            </td>
          </tr>

          <!-- CLINIC PAKKET -->
          <tr>
            <td style="padding:10px 0; vertical-align:middle; color:#64748b; font-weight:600; border-top:1px solid #f1f5f9;">Pakket:</td>
            <td style="padding:10px 0; vertical-align:middle; font-weight:800; color:#FF6B00; border-top:1px solid #f1f5f9;">
              ${escapeHtml(clinicLabel)}
            </td>
          </tr>

          ${personen ? `
          <tr>
            <td style="padding:10px 0; vertical-align:middle; color:#64748b; font-weight:600; border-top:1px solid #f1f5f9;">Aantal personen:</td>
            <td style="padding:10px 0; vertical-align:middle; font-weight:700; color:#0f172a; border-top:1px solid #f1f5f9;">
              ${escapeHtml(personen)}
            </td>
          </tr>` : ''}

          ${datum ? `
          <tr>
            <td style="padding:10px 0; vertical-align:middle; color:#64748b; font-weight:600; border-top:1px solid #f1f5f9;">Voorkeursdatum:</td>
            <td style="padding:10px 0; vertical-align:middle; font-weight:700; color:#0f172a; border-top:1px solid #f1f5f9;">
              ${escapeHtml(datum)}
            </td>
          </tr>` : ''}

          <tr>
            <td style="padding:10px 0; vertical-align:middle; color:#64748b; font-weight:600; border-top:1px solid #f1f5f9;">Locatie:</td>
            <td style="padding:10px 0; vertical-align:middle; color:#0f172a; border-top:1px solid #f1f5f9;">
              ${escapeHtml(locatie)}
            </td>
          </tr>

          ${opmerkingen ? `
          <tr>
            <td style="padding:10px 0; vertical-align:top; color:#64748b; font-weight:600; border-top:1px solid #f1f5f9;">Opmerkingen:</td>
            <td style="padding:10px 0; vertical-align:top; color:#334155; border-top:1px solid #f1f5f9; font-style:italic; background-color:#f8fafc; padding:10px 12px; border-radius:8px;">
              "${escapeHtml(opmerkingen)}"
            </td>
          </tr>` : ''}

          <tr>
            <td style="padding:10px 0; vertical-align:middle; color:#64748b; font-weight:600; border-top:1px solid #f1f5f9;">Bron:</td>
            <td style="padding:10px 0; vertical-align:middle; color:#64748b; font-size:13px; border-top:1px solid #f1f5f9;">
              ${escapeHtml(bron)} &bull; ${escapeHtml(formattedTimestamp)}
            </td>
          </tr>

        </table>

        <!-- DIRECT BEL- EN WHATSAPP KNOPPEN VOOR EDWARD -->
        ${telefoon ? `
        <div style="margin-top:28px; text-align:center;">
          <a href="tel:${escapeHtml(telefoon.replace(/[^0-9+]/g, ''))}" style="display:inline-block; background-color:#FF6B00; color:#ffffff; font-size:16px; font-weight:800; text-decoration:none; padding:14px 28px; border-radius:30px; box-shadow:0 4px 14px rgba(255,107,0,0.35); margin-right:8px; margin-bottom:8px;">
            📞 Bel ${escapeHtml(naam)}: ${escapeHtml(telefoon)}
          </a>
          <a href="https://wa.me/${escapeHtml(telefoon.replace(/[^0-9]/g, ''))}" target="_blank" style="display:inline-block; background-color:#25D366; color:#ffffff; font-size:16px; font-weight:800; text-decoration:none; padding:14px 28px; border-radius:30px; box-shadow:0 4px 14px rgba(37,211,102,0.35); margin-bottom:8px;">
            💬 WhatsApp Direct
          </a>
        </div>
        ` : ''}
      </td>
    </tr>

    <!-- FOOTER -->
    <tr>
      <td style="padding:18px 30px; background-color:#f8fafc; border-top:1px solid #e2e8f0; text-align:center; font-size:12px; color:#64748b;">
        Ontvangen via <strong>ttclinics.nl</strong> &bull; TTV The Victory, Driebekenweg 4, 1383 PX Weesp &bull; Tel: 06 - 11618060
      </td>
    </tr>

  </table>
</body>
</html>`;

    // 4. Verzend e-mail notificatie
    // Ontvangers: Standaard naar Edward & beheerder
    const recipients = (process.env.NOTIFY_EMAILS || 'edward@ttclinics.nl, schipperwonen@gmail.com')
      .split(',')
      .map(e => e.trim())
      .filter(Boolean);

    let sentVia = 'geen';

    // A. Via Resend API (indien RESEND_API_KEY ingesteld staat)
    if (process.env.RESEND_API_KEY) {
      try {
        const resendResp = await fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${process.env.RESEND_API_KEY}`,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            from: process.env.RESEND_FROM || 'TT Clinics Aanvragen <onboarding@resend.dev>',
            to: recipients,
            reply_to: email || undefined,
            subject: subject,
            text: plainText,
            html: htmlMsg
          })
        });

        if (resendResp.ok) {
          sentVia = 'Resend';
        } else {
          console.error('Resend error:', await resendResp.text());
        }
      } catch (resendErr) {
        console.error('Resend fetch exception:', resendErr);
      }
    }

    // B. Via Brevo / Sendinblue (indien BREVO_API_KEY ingesteld staat)
    if (sentVia === 'geen' && process.env.BREVO_API_KEY) {
      try {
        const brevoResp = await fetch('https://api.brevo.com/v3/smtp/email', {
          method: 'POST',
          headers: {
            'api-key': process.env.BREVO_API_KEY,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            sender: { name: 'TT Clinics', email: 'info@ttclinics.nl' },
            to: recipients.map(e => ({ email: e })),
            replyTo: email ? { email: email, name: naam } : undefined,
            subject: subject,
            textContent: plainText,
            htmlContent: htmlMsg
          })
        });

        if (brevoResp.ok) {
          sentVia = 'Brevo';
        }
      } catch (brevoErr) {
        console.error('Brevo error:', brevoErr);
      }
    }

    console.log(`[Aanvraag Ontvangen] ${naam} - ${telefoon} - ${clinicLabel} (Verzonden via: ${sentVia})`);

    return res.status(200).json({
      success: true,
      message: 'Aanvraag succesvol ontvangen! Edward neemt z.s.m. contact op.',
      sentVia: sentVia,
      timestamp: formattedTimestamp,
      data: {
        naam,
        telefoon,
        email,
        bedrijf,
        clinic: clinicLabel
      }
    });

  } catch (error) {
    console.error('Fout bij verwerken aanvraag:', error);
    return res.status(500).json({
      error: 'Er is een interne fout opgetreden bij het verzenden van de aanvraag.',
      details: error.message
    });
  }
}

function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}
