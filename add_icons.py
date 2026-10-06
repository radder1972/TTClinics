import re

with open('/Users/matthias/Downloads/tt-clinics-website/index.html', 'r') as f:
    html = f.read()

# Define the SVGs
svg_home = """<svg class="w-4 h-4 mr-1.5 inline-block group-hover:text-tt-orange transition-colors" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" /><circle cx="12" cy="14" r="2.5" fill="currentColor" stroke="none" /></svg>"""
svg_clinics = """<svg class="w-4 h-4 mr-1.5 inline-block group-hover:text-tt-orange transition-colors transform group-hover:rotate-12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="10.5" y="15" width="3" height="7" rx="1" /><ellipse cx="12" cy="9" rx="5" ry="6" /><circle cx="19" cy="5" r="2" fill="currentColor" stroke="none" /><path stroke-linecap="round" stroke-linejoin="round" d="M16 6h-2M15 3l-1.5 1.5" /></svg>"""
svg_over_ons = """<svg class="w-4 h-4 mr-1.5 inline-block group-hover:text-tt-orange transition-colors" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="12" cy="7" r="4" /><path stroke-linecap="round" stroke-linejoin="round" d="M6 21v-2a4 4 0 0 1 4-4h4a4 4 0 0 1 4 4v2" /><ellipse cx="19" cy="13" rx="2" ry="3" /><path stroke-linecap="round" stroke-linejoin="round" d="M19 16v3" /></svg>"""
svg_contact = """<svg class="w-4 h-4 mr-1.5 inline-block group-hover:text-tt-orange transition-colors" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="3" y="6" width="18" height="12" rx="2" /><path stroke-linecap="round" stroke-linejoin="round" d="M3 6l9 6 9-6" /><circle cx="12" cy="12" r="1.5" fill="currentColor" stroke="none" /></svg>"""
svg_dark_mode = """
<svg id="iconLight" class="w-5 h-5 hidden dark:block text-tt-orange" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" title="Light Mode">
    <!-- Glowing Ping Pong Ball (Sun) -->
    <circle cx="12" cy="12" r="5" fill="currentColor" stroke="none" />
    <path stroke-linecap="round" stroke-linejoin="round" d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41" />
</svg>
<svg id="iconDark" class="w-5 h-5 block dark:hidden text-tt-black" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" title="Dark Mode">
    <!-- Paddle Eclipse (Moon) -->
    <path stroke-linecap="round" stroke-linejoin="round" d="M20 13.5A8.5 8.5 0 1 1 10.5 4a7.5 7.5 0 0 0 9.5 9.5z" fill="currentColor" stroke="none"/>
    <rect x="8" y="16" width="2" height="6" rx="1" transform="rotate(-45 9 19)" fill="currentColor" stroke="none" />
</svg>
"""

# Replace the text links with text + icon
html = html.replace('<li><a href="#" class="hover:text-tt-orange transition-colors text-tt-black dark:text-white">Home</a></li>', f'<li><a href="#" class="group flex items-center hover:text-tt-orange transition-colors text-tt-black dark:text-white">{svg_home} Home</a></li>')
html = html.replace('<li><a href="#" class="hover:text-tt-orange transition-colors text-tt-black dark:text-white">Clinics</a></li>', f'<li><a href="#" class="group flex items-center hover:text-tt-orange transition-colors text-tt-black dark:text-white">{svg_clinics} Clinics</a></li>')
html = html.replace('<li><a href="#" class="hover:text-tt-orange transition-colors text-tt-black dark:text-white">Over Ons</a></li>', f'<li><a href="#" class="group flex items-center hover:text-tt-orange transition-colors text-tt-black dark:text-white">{svg_over_ons} Over Ons</a></li>')
html = html.replace('<li><a href="#" class="hover:text-tt-orange transition-colors text-tt-black dark:text-white">Contact</a></li>', f'<li><a href="#" class="group flex items-center hover:text-tt-orange transition-colors text-tt-black dark:text-white">{svg_contact} Contact</a></li>')

# Replace theme toggle button
html = html.replace('<li><button id="themeToggle" class="ml-4 p-2 bg-gray-100 dark:bg-gray-800 rounded-full hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors" title="Toggle Dark Mode">🌓</button></li>', f'<li><button id="themeToggle" class="ml-4 p-2 bg-gray-100 dark:bg-gray-800 rounded-full hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors flex items-center justify-center">{svg_dark_mode}</button></li>')

with open('/Users/matthias/Downloads/tt-clinics-website/index.html', 'w') as f:
    f.write(html)
