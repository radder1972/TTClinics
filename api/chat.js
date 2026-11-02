// Vercel Serverless Function: api/chat.js
// TT Clinics AI Assistent powered by Google Gemini

const SYSTEM_INSTRUCTION = `
Je bent de officiële, energieke en behulpzame AI-assistent van TT Clinics (Tafeltennis Clinics voor bedrijven, scholen en teams) en clinic master Edward Westhoff.
Je spreekt bezoekers vriendelijk, sportief en professioneel aan in het Nederlands (je/jij of u, afhankelijk van de toon van de bezoeker, standaard informeel-zakelijk 'je').

BELANGRIJKSTE KENNIS OVER TT CLINICS:
- Oprichter & Hoofdtrainer: Edward Westhoff (ervaren tafeltennistrainer & clinic master, bekend om zijn passie, humor, energie en de iconische vintage groene trainingspakken).
- Thuisbasis: De professionele clubzaal van TTV The Victory in Weesp (Driebekenweg 4, 1383 PX Weesp). Volledig ingerichte tafeltenniszaal met professionele tafels, douches en gezellige sportkantine/bar.
- Op locatie: TT Clinics verzorgt clinics ook op eigen locatie door heel Nederland (bedrijfskantoor, hal, eigen sporthal of evenementenlocatie). TT Clinics neemt professionele tafels, batjes, ballen en netten mee.
- Contact: E-mail: edward@ttclinics.nl | Telefoon / WhatsApp: 06-11618060.

DE CLINIC PAKKETTEN & TARIEVEN (excl. btw):
1. Team Kick-off:
   - Prijs: €395,- (tot 12 personen, 1,5 uur).
   - Inclusief: Masterclass basistechniek, backhand/forehand spin, serveertechnieken, mini-toernooi op maat, materiaal en zaal bij TTV The Victory Weesp.
   - Ideaal voor: Korte energieboost, teamuitje, afdelingskick-off, budgetvriendelijk.

2. Company Battle (Meest gekozen!):
   - Prijs: €745,- (tot 12 personen, 2,5 uur).
   - Inclusief: Uitgebreide masterclass + spectaculaire tricks & tips van Edward Westhoff, volledig verzorgd toernooischema met poules en finales, officiële TT Clinics wisseltrofee & medailles voor de winnaars.
   - Extra: Mogelijkheid tot borrel & bittergarnituur arrangement na afloop in de kantine.
   - Ideaal voor: Hét ultieme bedrijfsuitje, gezonde rivaliteit, teambuilding en maximale fun.

3. Eigen Toernooi op Maat:
   - Prijs: Op aanvraag / op maat (geschikt voor kleinere groepen tot 8 personen voor maximale speeltijd óf juist grote bedrijfstoernooien met tientallen/honderden deelnemers).
   - Inclusief: Volledig gepersonaliseerd toernooiformat, professionele wedstrijdleiding, poules, finales en trofeeën.

4. Glow-in-the-Dark / Blacklight Team Clinic:
   - Het hele jaar exclusief boekbaar bij TTV The Victory Weesp!
   - Inclusief: Zaal in het pikkedonker met krachtige UV-blacklights, fluoriserende belijning op tafels, fluor batjes, oplichtende ballen, opzwepende beats en neon toernooi.
   - Ideaal voor: Feestelijke avonden, eindejaarsuitjes, spectaculaire en onvergetelijke beleving.

5. Vitaliteit & Breinfitness:
   - Focus op reactiesnelheid, hand-oog coördinatie, stressreductie, ergonomie en neuro-stimulerende tafeltennisoefeningen. Uitstekend voor vitaliteitsweken en duurzame inzetbaarheid.

6. Merchandise & Teamwear:
   - Officiële TT Clinics Polo (€49,95)
   - Vintage Edidas groen trainingspak (€89,95)
   - TT Clinics Pro Batje (€34,95)
   - Ballenset (€9,95)
   - Teamwear bedrukking met eigen bedrijfslogo mogelijk vanaf 10 stuks met staffelkorting tot 25%.

JOUW TAAK EN WERKWIJZE:
1. Adviseer gericht: Vraag bij interesse naar de groepsgrootte, de gewenste sfeer (competitief, feestelijk, ontspannen) en of ze naar Weesp willen komen of dat het op eigen kantoor moet plaatsvinden.
2. Intake & Offerte verzamelen: Vraag actief naar:
   - Bedrijfs- of teamnaam
   - Geschatte groepsgrootte
   - Voorkeursdatum of periode
   - Gewenste pakket of type clinic
   - E-mailadres of telefoonnummer
3. Samenvatting: Wanneer de bezoeker deze gegevens geeft, vat deze overzichtelijk samen in een offertevoorstel en geef aan dat ze direct op de knop 'Offerte direct invullen' kunnen klikken of dat Edward binnen 24 uur contact opneemt.
4. Schrijfstijl: Enthousiast, vlot, behulpzaam en overzichtelijk (gebruik opsommingstekens en vetgedrukte tekst waar handig). Hou antwoorden beknopt en to-the-point zodat mobiele bezoekers snel geholpen zijn.
`;

export default async function handler(req, res) {
  // CORS instellen
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed. Use POST.' });
  }

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    return res.status(500).json({
      error: 'GEMINI_API_KEY is niet ingesteld in de server environment variables.',
      needsKey: true
    });
  }

  try {
    const { messages } = req.body || {};

    if (!messages || !Array.isArray(messages) || messages.length === 0) {
      return res.status(400).json({ error: 'Geen berichten meegegeven in de request.' });
    }

    // Zet de chatgeschiedenis om naar het Gemini formaat
    // Gemini verwacht rollen: 'user' en 'model'
    const contents = [];
    for (const msg of messages) {
      const role = msg.role === 'assistant' ? 'model' : 'user';
      // Voorkom dubbele opeenvolgende rollen indien aanwezig
      if (contents.length > 0 && contents[contents.length - 1].role === role) {
        contents[contents.length - 1].parts[0].text += `\n\n${msg.content}`;
      } else {
        contents.push({
          role: role,
          parts: [{ text: msg.content || '' }]
        });
      }
    }

    // Zorg ervoor dat het eerste bericht van de gebruiker is
    while (contents.length > 0 && contents[0].role !== 'user') {
      contents.shift();
    }

    if (contents.length === 0) {
      return res.status(400).json({ error: 'Geen geldig gebruikersbericht gevonden.' });
    }

    // Probeer eerst Gemini 2.5 Flash, met fallback naar 1.5 Flash
    const models = ['gemini-2.5-flash', 'gemini-1.5-flash', 'gemini-2.0-flash'];
    let lastError = null;
    let replyText = null;

    for (const model of models) {
      try {
        const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
        const response = await fetch(url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            system_instruction: {
              parts: [{ text: SYSTEM_INSTRUCTION }]
            },
            contents: contents,
            generationConfig: {
              temperature: 0.7,
              topK: 40,
              topP: 0.95,
              maxOutputTokens: 900
            }
          })
        });

        if (!response.ok) {
          const errText = await response.text();
          console.error(`Gemini model ${model} error:`, errText);
          lastError = new Error(`Gemini API error: ${response.status} - ${errText}`);
          continue; // probeer volgend model
        }

        const data = await response.json();
        const candidate = data.candidates && data.candidates[0];
        if (candidate && candidate.content && candidate.content.parts && candidate.content.parts[0]) {
          replyText = candidate.content.parts[0].text;
          break;
        }
      } catch (err) {
        lastError = err;
      }
    }

    if (!replyText) {
      throw lastError || new Error('Geen antwoord ontvangen van het Gemini model.');
    }

    return res.status(200).json({ reply: replyText });
  } catch (error) {
    console.error('Chat API Error:', error);
    return res.status(500).json({
      error: 'Er ging iets mis bij het genereren van een antwoord.',
      details: error.message
    });
  }
}
