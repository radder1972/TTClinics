import re

with open('/Users/matthias/Downloads/tt-clinics-website/index.html', 'r') as f:
    html = f.read()

# 1. Shrink Hero Section ("Antraciet Kop") and add the animated ball with swooshes
hero_old = """    <!-- Hero Section -->
    <header class="hero-section relative bg-tt-grey overflow-hidden">
        <div class="absolute inset-0 bg-tt-black/80 z-10"></div>
        <div class="hero-bg absolute inset-0 bg-cover bg-center"></div>
        
        <div class="container mx-auto px-4 py-32 relative z-20 flex flex-col items-center text-center">
            <h1 class="font-montserrat text-5xl md:text-7xl font-black text-white italic mb-4 uppercase tracking-tight">
                Dynamiek & <span class="text-tt-orange">Snelheid</span>
            </h1>
            <p class="text-xl text-gray-200 max-w-2xl mb-8 font-light">
                Verbeter je tafeltennis skills met professionele clinics voor alle niveaus. Ontdek de kracht van techniek en tactiek.
            </p>
            <a href="#contact" class="btn-speed bg-tt-orange hover:bg-orange-600 text-white font-bold py-3 px-8 rounded-full transition-all transform hover:scale-105 shadow-lg">
                Boek een Clinic
            </a>
        </div>
    </header>"""

# We make it a compact "label" style banner.
hero_new = """    <!-- Hero Banner / Booking Label -->
    <header class="hero-section relative bg-tt-black overflow-hidden py-12 border-b-8 border-tt-orange shadow-inner">
        <div class="hero-bg absolute inset-0 bg-cover bg-center opacity-20"></div>
        
        <div class="container mx-auto px-4 relative z-20 flex flex-col items-center text-center">
            <h1 class="font-montserrat text-4xl md:text-5xl font-black text-white italic mb-2 uppercase tracking-tight relative inline-block">
                Dynamiek & <span class="text-tt-orange">Snelheid</span>
                <!-- SVG Swoosh Ball flying under the text -->
                <div class="absolute -bottom-8 left-1/2 transform -translate-x-1/2 w-48 h-8">
                    <svg viewBox="0 0 200 40" fill="none" class="w-full h-full text-tt-orange animate-pulse">
                        <path d="M10,20 Q80,5 150,20" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-dasharray="8 4" opacity="0.5"/>
                        <path d="M20,25 Q90,10 160,25" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-dasharray="6 6" opacity="0.3"/>
                        <circle cx="170" cy="22" r="8" fill="currentColor"/>
                        <circle cx="173" cy="20" r="2" fill="white" opacity="0.8"/>
                    </svg>
                </div>
            </h1>
            
            <div class="mt-12 bg-white/10 backdrop-blur-sm p-4 rounded-full border border-white/20 inline-flex items-center gap-4 shadow-xl">
                <span class="text-gray-200 font-medium hidden md:inline-block px-4">Klaar om je spel te verbeteren?</span>
                <a href="#contact" class="btn-speed bg-tt-orange hover:bg-orange-600 text-white font-bold py-2 px-8 rounded-full transition-all transform hover:scale-105 shadow-lg flex items-center">
                    Boek nu een Clinic
                    <svg class="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"></path></svg>
                </a>
            </div>
        </div>
    </header>"""

html = html.replace(hero_old, hero_new)

# 2. Make "Wat wij bieden" narrower.
# Search for: <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
# Replace with: <div class="grid grid-cols-1 md:grid-cols-3 gap-6 max-w-5xl mx-auto">
html = html.replace('<div class="grid grid-cols-1 md:grid-cols-3 gap-8">', '<div class="grid grid-cols-1 md:grid-cols-3 gap-6 max-w-5xl mx-auto">')

# 3. Just in case "antraciet kop" meant the middle card in "Wat wij bieden", 
# let's make it not completely black but rather a softer dark gray, or keep it consistent with the others but with an orange accent.
# User said: "Die kolommen hoeven niet zo breed."
# Let's change the middle card to be light gray like the others to remove the huge "antraciet" block if that's what they meant.
card_dark_old = """<div class="feature-card relative bg-tt-black dark:bg-black text-white p-8 shadow-md hover:shadow-xl transition-all overflow-hidden group" style="border-radius: 40px 0 40px 0;">"""
card_dark_new = """<div class="feature-card relative bg-gray-50 dark:bg-gray-800 dark:border-gray-700 dark:border text-tt-black dark:text-white p-8 shadow-md hover:shadow-xl transition-all overflow-hidden group" style="border-radius: 40px 0 40px 0; border-bottom: 4px solid #FF6B00;">"""
html = html.replace(card_dark_old, card_dark_new)

# Fix text color in that middle card
html = html.replace('<p class="text-gray-300 relative z-10">Begrijp het spel beter', '<p class="text-gray-600 dark:text-gray-300 relative z-10">Begrijp het spel beter')

with open('/Users/matthias/Downloads/tt-clinics-website/index.html', 'w') as f:
    f.write(html)
