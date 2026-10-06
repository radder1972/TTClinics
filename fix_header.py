import re

with open('/Users/matthias/Downloads/tt-clinics-website/index.html', 'r') as f:
    html = f.read()

# Replace the hero header
hero_old_pattern = re.compile(r'<!-- Hero Banner / Booking Label -->.*?</header>', re.DOTALL)

hero_new = """    <!-- Hero Banner / Booking Label -->
    <div class="bg-tt-orange slant-bottom mb-8">
        <header class="hero-section relative bg-tt-black dark:bg-black overflow-hidden pt-8 pb-16 slant-bottom-inner" style="margin-bottom: 4px;">
            <div class="hero-bg absolute inset-0 bg-cover bg-center opacity-20"></div>
            
            <div class="container mx-auto px-4 relative z-20 flex flex-col md:flex-row items-center justify-between">
                <div class="flex-1 text-left">
                    <h1 class="font-montserrat text-3xl md:text-4xl font-black text-white italic uppercase tracking-tight relative mb-2 inline-block">
                        Dynamiek & <span class="text-tt-orange">Snelheid</span>
                        <!-- SVG Swoosh Ball flying under the text -->
                        <div class="absolute -bottom-5 left-0 w-48 h-6">
                            <svg viewBox="0 0 200 40" fill="none" class="w-full h-full text-tt-orange animate-pulse">
                                <path d="M10,20 Q80,5 150,20" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-dasharray="8 4" opacity="0.5"/>
                                <path d="M20,25 Q90,10 160,25" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-dasharray="6 6" opacity="0.3"/>
                                <circle cx="170" cy="22" r="8" fill="currentColor"/>
                                <circle cx="173" cy="20" r="2" fill="white" opacity="0.8"/>
                            </svg>
                        </div>
                    </h1>
                </div>
                
                <div class="mt-8 md:mt-0 ml-0 md:ml-8">
                    <a href="#contact" class="btn-speed bg-tt-orange hover:bg-orange-600 text-white font-bold py-3 px-8 rounded-full transition-all transform hover:scale-105 shadow-lg flex items-center">
                        Boek een Clinic
                        <svg class="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"></path></svg>
                    </a>
                </div>
            </div>
        </header>
    </div>"""

html = hero_old_pattern.sub(hero_new, html)

with open('/Users/matthias/Downloads/tt-clinics-website/index.html', 'w') as f:
    f.write(html)

# Add CSS for slant-bottom
with open('/Users/matthias/Downloads/tt-clinics-website/css/style.css', 'a') as f:
    f.write("""
/* Top Header Slant */
.slant-bottom {
    clip-path: polygon(0 0, 100% 0, 100% calc(100% - 3vw), 0 100%);
}
.slant-bottom-inner {
    clip-path: polygon(0 0, 100% 0, 100% calc(100% - 3vw), 0 100%);
}
""")
