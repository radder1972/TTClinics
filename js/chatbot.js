/**
 * TT Clinics - AI Chatbot Assistent
 * Geïntegreerd met Vercel Serverless Function & Google Gemini API
 */

(function () {
  'use strict';

  // Google Gemini API Key fallback (voor naadloze werking op statische hosting & lokaal)
  const FALLBACK_GEMINI_KEY = (function() {
    try {
      return atob('QVEuQWI4Uk42TGpkamdNT2dscVJqLWRXaUJfeTc0UUROMUFYb3lkbnV5V19hemVxcUdzNnc=');
    } catch (e) {
      return '';
    }
  })();

  // Lokale kennisbank & slimme fallback antwoorden voor directe respons
  const SMART_FALLBACKS = {
    tarieven: `Onze clinic-pakketten op een rij (excl. btw):\n\n- **Company Battle** (Meest gekozen!): €745,- (tot 12 personen · 2,5 uur) inclusief tricks & tips, competitie toernooi en officiële TT Clinics trofee & medailles.\n- **Team Kick-off**: €395,- (tot 12 personen · 1,5 uur) inclusief techniek & toernooi.\n- **Glow-in-the-Dark / Blacklight Clinic**: Spectaculair toernooi in het donker met neon en fluor.\n- **Eigen Toernooi op Maat**: Voor kleine groepen (tot 8 personen) of grote bedrijfsevents op maat.\n\nAlle clinics in Weesp zijn inclusief zaalhuur, batjes en ballen!`,
    battle: `De **Company Battle** (€745,- excl. btw) is ons populairste bedrijfsuitje! 🏆\n\nWat kun je verwachten:\n- Tot 12 personen (grotere groepen op aanvraag)\n- Duur: 2,5 uur vol energie en actie\n- Complete clinic + tricks & tips van Edward Westhoff\n- Volledig verzorgd toernooischema (poules & finales)\n- Officiële TT Clinics wisseltrofee & medailles\n- Optioneel: aansluitend een gezellige borrel & bittergarnituur in de bar van The Victory Weesp!`,
    kickoff: `De **Team Kick-off** (€395,- excl. btw) is ideaal voor een snelle, energieke teambuilding boost! 🏓\n\n- Tot 12 personen · 1,5 uur\n- Masterclass basistechniek, forehand/backhand spin en serveertrucs\n- Afsluitend toernooi op maat\n- Inclusief professionele zaal bij TTV The Victory Weesp en alle materialen.`,
    blacklight: `Onze **Glow-in-the-Dark / Blacklight Clinic** is een unieke beleving! 🔮✨\n\n- Het hele jaar exclusief boekbaar bij TTV The Victory in Weesp.\n- De zaal gaat pikkedonker: UV-blacklights aan, fluor tape op de tafels, lichtgevende ballen en fluor batjes.\n- Met opzwepende muziek en een energiek glow-toernooi.\n- Geweldig voor teamfeesten, jubilea of het einde van het jaar!`,
    locatie: `We bieden clinics aan op twee manieren:\n\n1. **Thuisbasis Weesp**: Onze professionele clubzaal bij **TTV The Victory** (Driebekenweg 4, 1383 PX Weesp) – inclusief douches, kleedkamers en een sfeervolle bar/kantine.\n2. **Op jullie eigen locatie**: We komen met professionele tafels, netten, batjes en ballen naar jullie bedrijfshal, kantoor of een sportzaal in heel Nederland!`,
    edward: `**Edward Westhoff** is de oprichter en clinic master van TT Clinics! 🏓\n\nAls voormalig topspeler en gediplomeerd trainer combineert Edward diepgaande techniek met humor, energie en de iconische vintage groene 'Edidas' vibe. Geen saaie drills, maar maximaal plezier en gezonde teamcompetitie!`
  };

  class TTChatbot {
    constructor() {
      this.isOpen = false;
      this.messages = [];
      this.apiEndpoint = '/api/chat';
      this.localApiKey = localStorage.getItem('tt_gemini_key') || FALLBACK_GEMINI_KEY;
      this.intakeState = {
        naam: '',
        bedrijf: '',
        personen: '',
        pakket: 'battle',
        datum: '',
        locatie: 'Weesp'
      };

      this.init();
    }

    init() {
      this.injectHTML();
      this.cacheElements();
      this.bindEvents();

      // Start met welkomstbericht
      if (this.messages.length === 0) {
        this.addBotMessage(
          `Hoi! Welkom bij **TT Clinics** 🏓\n\nIk help je graag met advies over onze energieke tafeltennisclinics, tarieven of een offerte op maat.\n\nWaar ben je naar op zoek?`,
          true
        );
      }

      // Toon callout hint na 2,5 seconden als bot nog niet geopend is
      setTimeout(() => {
        if (!this.isOpen && this.calloutEl) {
          this.calloutEl.style.display = 'flex';
        }
      }, 2500);
    }

    injectHTML() {
      if (document.getElementById('tt-chatbot-container')) return;

      const container = document.createElement('div');
      container.id = 'tt-chatbot-container';
      container.innerHTML = `
        <!-- Floating Launcher Button: In de exacte TT Clinics tt-icon-ball stijl -->
        <div id="ttChatLauncher" class="tt-chat-launcher" role="button" aria-label="Open TT Clinics Assistent" title="Vraag de TT Clinics Assistent">
          <svg class="w-7 h-7 filter drop-shadow-sm" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <path d="M12 2v4"></path>
            <circle cx="12" cy="2" r="1.5" fill="currentColor"></circle>
            <rect width="16" height="12" x="4" y="6" rx="3"></rect>
            <circle cx="9" cy="11" r="1.2" fill="currentColor"></circle>
            <circle cx="15" cy="11" r="1.2" fill="currentColor"></circle>
            <path d="M9 14.5c1 .8 2 1 3 1s2-.2 3-1"></path>
            <path d="M2 12h2"></path>
            <path d="M20 12h2"></path>
          </svg>
          <span class="tt-status-dot"></span>
        </div>

        <!-- Popover Hint Callout -->
        <div id="ttChatCallout" class="tt-chat-callout" style="display: none;">
          <span>Vragen over een clinic of offerte?</span>
          <button id="ttCalloutClose" class="tt-callout-close" aria-label="Sluit hint">&times;</button>
        </div>

        <!-- Chat Window -->
        <div id="ttChatWindow" class="tt-chat-window" aria-hidden="true">
          <!-- Header -->
          <div class="tt-chat-header">
            <div class="tt-header-left">
              <div class="tt-header-avatar">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                  <path d="M12 2v4"></path>
                  <circle cx="12" cy="2" r="1.5" fill="currentColor"></circle>
                  <rect width="16" height="12" x="4" y="6" rx="3"></rect>
                  <circle cx="9" cy="11" r="1.2" fill="currentColor"></circle>
                  <circle cx="15" cy="11" r="1.2" fill="currentColor"></circle>
                  <path d="M9 14.5c1 .8 2 1 3 1s2-.2 3-1"></path>
                  <path d="M2 12h2"></path>
                  <path d="M20 12h2"></path>
                </svg>
              </div>
              <div class="tt-header-info">
                <h4>TT Clinics Assistent</h4>
                <p>Online • Direct advies &amp; offerte</p>
              </div>
            </div>
            <div class="tt-header-actions">
              <button id="ttResetBtn" class="tt-header-btn" title="Gesprek wissen" aria-label="Gesprek wissen">
                <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
              </button>
              <button id="ttCloseBtn" class="tt-header-btn" title="Sluit venster" aria-label="Sluit venster">
                <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/></svg>
              </button>
            </div>
          </div>

          <!-- Chat body -->
          <div id="ttChatBody" class="tt-chat-body">
            <!-- Messages container -->
            <div id="ttChatMessages" class="flex flex-col gap-3"></div>

            <!-- Quick Action Chips (Huisstijl SVG iconen) -->
            <div id="ttQuickChips" class="tt-quick-chips">
              <button class="tt-chip" data-prompt="Welk clinic-pakket past het beste bij ons team?">
                <svg class="w-3.5 h-3.5 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9H4.5a2.5 2.5 0 0 1 0-5H6"/><path d="M18 9h1.5a2.5 2.5 0 0 0 0-5H18"/><path d="M4 22h16"/><path d="M10 14.66V17c0 .55-.45 1-1 1H7v4h10v-4h-2c-.55 0-1-.45-1-1v-2.34"/><path d="M18 2H6v7a6 6 0 0 0 12 0V2z"/></svg>
                <span>Welk pakket past bij ons?</span>
              </button>
              <button class="tt-chip" data-prompt="Wat zijn de tarieven van jullie clinics?">
                <svg class="w-3.5 h-3.5 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
                <span>Tarieven &amp; Pakketten</span>
              </button>
              <button class="tt-chip" data-prompt="Vertel me over de Glow-in-the-Dark / Blacklight clinic!">
                <svg class="w-3.5 h-3.5 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="m12 3-1.9 5.8a2 2 0 0 1-1.3 1.3L3 12l5.8 1.9a2 2 0 0 1 1.3 1.3L12 21l1.9-5.8a2 2 0 0 1 1.3-1.3L21 12l-5.8-1.9a2 2 0 0 1-1.3-1.3L12 3z"/></svg>
                <span>Blacklight clinic</span>
              </button>
              <button class="tt-chip" data-prompt="Komen jullie ook op onze eigen bedrijfslocatie?">
                <svg class="w-3.5 h-3.5 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/></svg>
                <span>Locaties (Weesp of eigen kantoor)</span>
              </button>
              <button class="tt-chip" data-prompt="Ik wil graag direct een offerte of optie aanvragen.">
                <svg class="w-3.5 h-3.5 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><rect width="8" height="4" x="8" y="2" rx="1" ry="1"/><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><path d="M9 12h6M9 16h6"/></svg>
                <span>Offerte aanvragen</span>
              </button>
            </div>

            <!-- Typing indicator -->
            <div id="ttTypingIndicator" class="tt-typing-indicator" style="display: none;">
              <span class="tt-typing-dot"></span>
              <span class="tt-typing-dot"></span>
              <span class="tt-typing-dot"></span>
            </div>
          </div>

          <!-- Footer / Input -->
          <form id="ttChatForm" class="tt-chat-footer">
            <input
              type="text"
              id="ttChatInput"
              class="tt-chat-input"
              placeholder="Typ je vraag..."
              autocomplete="off"
            />
            <button type="submit" id="ttChatSendBtn" class="tt-chat-send" aria-label="Verstuur bericht">
              <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M5 12h14M12 5l7 7-7 7"/></svg>
            </button>
          </form>
        </div>
      `;

      document.body.appendChild(container);
    }

    cacheElements() {
      this.launcherEl = document.getElementById('ttChatLauncher');
      this.calloutEl = document.getElementById('ttChatCallout');
      this.calloutCloseEl = document.getElementById('ttCalloutClose');
      this.windowEl = document.getElementById('ttChatWindow');
      this.closeBtn = document.getElementById('ttCloseBtn');
      this.resetBtn = document.getElementById('ttResetBtn');
      this.bodyEl = document.getElementById('ttChatBody');
      this.messagesEl = document.getElementById('ttChatMessages');
      this.quickChipsEl = document.getElementById('ttQuickChips');
      this.typingEl = document.getElementById('ttTypingIndicator');
      this.formEl = document.getElementById('ttChatForm');
      this.inputEl = document.getElementById('ttChatInput');
      this.sendBtn = document.getElementById('ttChatSendBtn');
    }

    bindEvents() {
      // Toggle chat window
      this.launcherEl.addEventListener('click', () => this.toggleChat());
      this.closeBtn.addEventListener('click', () => this.toggleChat(false));
      
      // Callout hint
      if (this.calloutEl) {
        this.calloutEl.addEventListener('click', (e) => {
          if (e.target !== this.calloutCloseEl) {
            this.toggleChat(true);
          }
        });
      }
      if (this.calloutCloseEl) {
        this.calloutCloseEl.addEventListener('click', (e) => {
          e.stopPropagation();
          this.calloutEl.style.display = 'none';
        });
      }

      // Reset
      this.resetBtn.addEventListener('click', () => this.resetConversation());

      // Quick Chips
      this.quickChipsEl.addEventListener('click', (e) => {
        const chip = e.target.closest('.tt-chip');
        if (chip && chip.dataset.prompt) {
          const prompt = chip.dataset.prompt;
          this.sendMessage(prompt);
        }
      });

      // Form submit
      this.formEl.addEventListener('submit', (e) => {
        e.preventDefault();
        const text = (this.inputEl.value || '').trim();
        if (text) {
          this.sendMessage(text);
          this.inputEl.value = '';
        }
      });

      // Escape key
      document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && this.isOpen) {
          this.toggleChat(false);
        }
      });
    }

    toggleChat(forceState) {
      this.isOpen = typeof forceState === 'boolean' ? forceState : !this.isOpen;
      const container = document.getElementById('tt-chatbot-container');

      if (this.isOpen) {
        this.windowEl.classList.add('is-open');
        this.windowEl.setAttribute('aria-hidden', 'false');
        if (container) container.classList.add('chat-is-open');
        if (this.calloutEl) this.calloutEl.style.display = 'none';
        setTimeout(() => this.inputEl.focus(), 200);
        this.scrollToBottom();
      } else {
        this.windowEl.classList.remove('is-open');
        this.windowEl.setAttribute('aria-hidden', 'true');
        if (container) container.classList.remove('chat-is-open');
      }
    }

    resetConversation() {
      this.messages = [];
      this.messagesEl.innerHTML = '';
      this.addBotMessage(
        `Gesprek gereset! 🏓 Waar kan ik je vandaag mee van dienst zijn?`,
        true
      );
      this.quickChipsEl.style.display = 'flex';
      this.scrollToBottom();
    }

    async sendMessage(userText) {
      if (!userText.trim()) return;

      // 1. Voeg toe aan UI
      this.addUserMessage(userText);
      this.inputEl.disabled = true;
      this.sendBtn.disabled = true;
      this.showTyping(true);

      // 2. Houd berichtenlijst bij
      this.messages.push({ role: 'user', content: userText });

      // Verberg chips na het eerste bericht om ruimte te maken
      if (this.quickChipsEl) {
        this.quickChipsEl.style.display = 'none';
      }

      // Check of er intake info in de tekst zit
      this.parseUserIntake(userText);

      try {
        let reply = await this.fetchAssistantReply();
        this.showTyping(false);
        this.addBotMessage(reply);
        this.messages.push({ role: 'assistant', content: reply });
      } catch (err) {
        console.warn('AI fetch error, utilizing smart fallback:', err);
        this.showTyping(false);
        
        // Gebruik intelligente fallback
        const fallbackText = this.generateFallbackResponse(userText);
        this.addBotMessage(fallbackText);
        this.messages.push({ role: 'assistant', content: fallbackText });
      } finally {
        this.inputEl.disabled = false;
        this.sendBtn.disabled = false;
        this.inputEl.focus();
        this.scrollToBottom();
      }
    }

    parseUserIntake(text) {
      const lower = text.toLowerCase();
      
      // Pakket herkenning
      if (lower.includes('battle') || lower.includes('company')) {
        this.intakeState.pakket = 'battle';
      } else if (lower.includes('kick') || lower.includes('kickoff')) {
        this.intakeState.pakket = 'kickoff';
      } else if (lower.includes('glow') || lower.includes('blacklight') || lower.includes('dark')) {
        this.intakeState.pakket = 'blacklight';
      } else if (lower.includes('maat') || lower.includes('toernooi')) {
        this.intakeState.pakket = 'toernooi-op-maat';
      }

      // Personen herkenning
      const numMatch = text.match(/(\d{1,3})\s*(mensen|personen|collega|pers)/i);
      if (numMatch) {
        this.intakeState.personen = numMatch[1];
      }

      // Locatie herkenning
      if (lower.includes('kantoor') || lower.includes('locatie') || lower.includes('bij ons') || lower.includes('bedrijf')) {
        this.intakeState.locatie = 'Op eigen locatie';
      } else if (lower.includes('weesp') || lower.includes('the victory')) {
        this.intakeState.locatie = 'TTV The Victory (Weesp)';
      }
    }

    async fetchAssistantReply() {
      // 1. Probeer Vercel Serverless Function /api/chat
      try {
        const response = await fetch(this.apiEndpoint, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ messages: this.messages })
        });

        if (response.ok) {
          const data = await response.json();
          if (data.reply) return data.reply;
        } else {
          const errData = await response.json().catch(() => ({}));
          // Als de server aangeeft dat GEMINI_API_KEY niet is ingesteld en we hebben een lokale key:
          if (this.localApiKey) {
            return await this.callGeminiDirect(this.localApiKey);
          }
          throw new Error(errData.error || `HTTP ${response.status}`);
        }
      } catch (networkErr) {
        // Indien /api/chat niet beschikbaar is (bijv. statische file:// server), probeer lokale key
        if (this.localApiKey) {
          return await this.callGeminiDirect(this.localApiKey);
        }
        throw networkErr;
      }
    }

    async callGeminiDirect(apiKey) {
      const contents = this.messages.map(m => ({
        role: m.role === 'assistant' ? 'model' : 'user',
        parts: [{ text: m.content }]
      }));

      const fullInstruction = `Je bent de officiële, energieke en behulpzame AI-assistent van TT Clinics en clinic master Edward Westhoff.
Tarieven & Pakketten:
- Company Battle (€745 excl btw, tot 12 personen, 2,5 uur) - Meest gekozen! Incl tricks & tips, competitie toernooi, wisselbeker en medailles.
- Team Kick-off (€395 excl btw, tot 12 personen, 1,5 uur) - Techniek, mini-toernooi.
- Glow-in-the-Dark / Blacklight Team Clinic - Pikkedonker met UV-lampen, neon tape en fluor batjes in Weesp.
- Eigen Toernooi op Maat - Voor kleine groepen tot 8 personen of grote bedrijfstoernooien.
Locaties: Professionele clubzaal TTV The Victory Weesp (Driebekenweg 4) én op eigen bedrijfslocatie door heel Nederland.
Contact: edward@ttclinics.nl, tel/WhatsApp 06-11618060.
Doel: Bezoekers adviseren, vragen beantwoorden en intakegegevens noteren voor een offerte.`;

      const body = {
        system_instruction: {
          parts: [{ text: fullInstruction }]
        },
        contents: contents,
        generationConfig: {
          temperature: 0.7,
          maxOutputTokens: 800
        }
      };

      const models = ['gemini-2.5-flash', 'gemini-1.5-flash'];
      let lastErr = null;

      for (const model of models) {
        try {
          const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
          const res = await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body)
          });

          if (!res.ok) {
            lastErr = new Error(`Gemini direct ${model} error: ${res.status}`);
            continue;
          }

          const data = await res.json();
          if (data.candidates && data.candidates[0]?.content?.parts?.[0]?.text) {
            return data.candidates[0].content.parts[0].text;
          }
        } catch (e) {
          lastErr = e;
        }
      }

      throw lastErr || new Error('Geen antwoord van Gemini ontvangen.');
    }

    generateFallbackResponse(userText) {
      const q = userText.toLowerCase();

      if (q.includes('tarief') || q.includes('prijs') || q.includes('kosten') || q.includes('prijzen') || q.includes('kost')) {
        return SMART_FALLBACKS.tarieven;
      }
      if (q.includes('battle') || q.includes('company battle')) {
        return SMART_FALLBACKS.battle;
      }
      if (q.includes('kick') || q.includes('kickoff') || q.includes('kick-off')) {
        return SMART_FALLBACKS.kickoff;
      }
      if (q.includes('glow') || q.includes('blacklight') || q.includes('donker') || q.includes('lichtgevend')) {
        return SMART_FALLBACKS.blacklight;
      }
      if (q.includes('locatie') || q.includes('waar') || q.includes('weesp') || q.includes('kantoor') || q.includes('adres')) {
        return SMART_FALLBACKS.locatie;
      }
      if (q.includes('edward') || q.includes('wie') || q.includes('trainer') || q.includes('coach')) {
        return SMART_FALLBACKS.edward;
      }
      if (q.includes('offerte') || q.includes('boeken') || q.includes('aanvragen') || q.includes('datum') || q.includes('reserveren')) {
        return `Wat leuk dat je interesse hebt in een clinic! 🎉\n\nOm een passend voorstel te maken heb ik een paar details nodig:\n1. Om welk bedrijf of team gaat het?\n2. Met hoeveel personen verwachten jullie te komen?\n3. Welke datum of periode heeft jullie voorkeur?\n\nJe kunt de gegevens ook direct invullen via het offerteformulier op de pagina!`;
      }

      // Algemeen respons
      return `Bedankt voor je bericht! 🏓\n\nOf het nu gaat om de populaire **Company Battle** (€745,-), een snelle **Team Kick-off** (€395,-) of een spectaculaire **Glow-in-the-Dark Clinic**: we stemmen alles perfect af op jullie team!\n\nWil je direct een voorstel op maat, of wil je meer weten over een specifiek pakket?`;
    }

    addUserMessage(text) {
      const timeStr = this.getCurrentTime();
      const div = document.createElement('div');
      div.className = 'tt-msg tt-msg-user';
      div.innerHTML = `
        <div class="tt-msg-bubble">${this.escapeHTML(text)}</div>
        <span class="tt-msg-time">${timeStr}</span>
      `;
      this.messagesEl.appendChild(div);
      this.scrollToBottom();
    }

    addBotMessage(text, isInitial = false) {
      const timeStr = this.getCurrentTime();
      const formattedHTML = this.formatMarkdown(text);
      const div = document.createElement('div');
      div.className = 'tt-msg tt-msg-bot';

      // Check of er offerte / actieknoppen toegevoegd moeten worden
      let actionsHTML = '';
      const lower = text.toLowerCase();
      const needsQuoteBtn = lower.includes('offerte') || lower.includes('voorstel') || lower.includes('boeken') || lower.includes('tarieven') || lower.includes('battle') || lower.includes('kick-off');

      if (needsQuoteBtn && !isInitial) {
        actionsHTML = `
          <div class="tt-chat-actions">
            <button type="button" class="tt-action-btn tt-fill-form-btn">
              <svg class="w-3.5 h-3.5 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><rect width="8" height="4" x="8" y="2" rx="1" ry="1"/><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><path d="M9 12h6M9 16h6"/></svg>
              <span>Offerteformulier invullen</span>
            </button>
            <a href="https://wa.me/31611618060?text=${encodeURIComponent('Hallo Edward, ik heb via de website interesse in een TT Clinic!')}" target="_blank" rel="noopener" class="tt-action-btn">
              <svg class="w-3.5 h-3.5 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/></svg>
              <span>WhatsApp Edward</span>
            </a>
          </div>
        `;
      }

      div.innerHTML = `
        <div class="tt-msg-bubble">
          ${formattedHTML}
          ${actionsHTML}
        </div>
        <span class="tt-msg-time">${timeStr}</span>
      `;

      // Event listener voor formulier invullen knop
      const fillBtn = div.querySelector('.tt-fill-form-btn');
      if (fillBtn) {
        fillBtn.addEventListener('click', () => this.handleFillForm());
      }

      this.messagesEl.appendChild(div);
      this.scrollToBottom();
    }

    handleFillForm() {
      // 1. Zoek het contact formulier op de pagina
      const contactSection = document.getElementById('contact');
      const selectPakket = document.getElementById('clinicInteresse');
      const msgField = document.getElementById('contactBericht') || contactSection?.querySelector('textarea');
      const naamField = document.getElementById('contactNaam');

      if (selectPakket && this.intakeState.pakket) {
        selectPakket.value = this.intakeState.pakket;
      }

      if (msgField) {
        const pakketNamen = {
          'battle': 'Company Battle (2,5 uur)',
          'kickoff': 'Team Kick-off (1,5 uur)',
          'blacklight': 'Glow-in-the-Dark / Blacklight Team Clinic',
          'toernooi-op-maat': 'Eigen Toernooi op Maat'
        };

        const gekozenPakket = pakketNamen[this.intakeState.pakket] || 'Company Battle';
        let samenvatting = `Hallo Edward,\n\nVia de chatbot assistent vraag ik graag een offerte / optie aan:\n`;
        samenvatting += `- Gewenst pakket: ${gekozenPakket}\n`;
        if (this.intakeState.personen) {
          samenvatting += `- Aantal personen: ca. ${this.intakeState.personen}\n`;
        }
        if (this.intakeState.locatie) {
          samenvatting += `- Voorkeurslocatie: ${this.intakeState.locatie}\n`;
        }
        samenvatting += `\nGraag vernemen we de mogelijkheden en beschikbaarheid!`;

        msgField.value = samenvatting;
      }

      // 2. Scroll soepel naar contact sectie
      if (contactSection) {
        contactSection.scrollIntoView({ behavior: 'smooth' });
        // Verklein de chat tijdelijk zodat bezoeker het formulier ziet
        this.toggleChat(false);

        // Geef focus aan het naamveld
        setTimeout(() => {
          if (naamField) naamField.focus();
        }, 600);
      }
    }

    showTyping(show) {
      if (this.typingEl) {
        this.typingEl.style.display = show ? 'flex' : 'none';
        if (show) this.scrollToBottom();
      }
    }

    scrollToBottom() {
      setTimeout(() => {
        if (this.bodyEl) {
          this.bodyEl.scrollTop = this.bodyEl.scrollHeight;
        }
      }, 50);
    }

    getCurrentTime() {
      const now = new Date();
      return now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    }

    escapeHTML(str) {
      return str
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
    }

    formatMarkdown(text) {
      if (!text) return '';
      
      let html = this.escapeHTML(text);

      // Vetgedrukt: **tekst**
      html = html.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');

      // Cursief: *tekst*
      html = html.replace(/\*(.*?)\*/g, '<em>$1</em>');

      // Lijst items (- item)
      html = html.replace(/(?:^|\n)-\s+(.*)/g, '<li>$1</li>');
      html = html.replace(/(<li>.*<\/li>)/s, '<ul>$1</ul>');

      // Genummerde lijst (1. item)
      html = html.replace(/(?:^|\n)\d+\.\s+(.*)/g, '<li>$1</li>');

      // Paragrafen en enters
      html = html.replace(/\n\n+/g, '</p><p>');
      html = html.replace(/\n/g, '<br>');

      return `<p>${html}</p>`;
    }
  }

  // Initialiseer wanneer DOM geladen is
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => new TTChatbot());
  } else {
    new TTChatbot();
  }
})();
