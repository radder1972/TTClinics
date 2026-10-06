import re

with open('/Users/matthias/Downloads/tt-clinics-website/index.html', 'r') as f:
    html = f.read()

# Add fixed background div right after <body>
body_tag = '<body class="bg-white dark:bg-gray-900 text-tt-black dark:text-gray-100 font-inter transition-colors duration-300">'

bg_div = """
    <!-- Abstract Table Tennis Background -->
    <div class="fixed inset-0 z-[-1] pointer-events-none overflow-hidden">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 800" class="w-full h-full object-cover opacity-60 dark:opacity-10" preserveAspectRatio="xMidYMid slice">
            <g transform="translate(500, 400) rotate(-15) skewX(-50) scale(1, 0.5) translate(-500, -400)">
                <!-- Table Base -->
                <rect x="300" y="200" width="400" height="600" fill="#FF6B00" fill-opacity="0.03" />
                <rect x="300" y="200" width="400" height="600" fill="none" stroke="#FF6B00" stroke-width="8" stroke-opacity="0.08" />
                <!-- Center Line -->
                <line x1="500" y1="200" x2="500" y2="800" stroke="#FF6B00" stroke-width="4" stroke-opacity="0.08" />
                <!-- Net (Thicker Line) -->
                <line x1="280" y1="500" x2="720" y2="500" stroke="#FF6B00" stroke-width="12" stroke-opacity="0.15" />
            </g>
        </svg>
    </div>
"""

html = html.replace(body_tag, body_tag + bg_div)

# Ensure sections that should be transparent are transparent, but some should have solid backgrounds.
# Hero is black, so it stays solid.
# "Wat wij bieden" (bg-white) - let's make it slightly transparent so the background shows through, or just leave it transparent!
# Find: <section class="py-20 bg-white dark:bg-gray-900 relative transition-colors duration-300">
# Wait, let's keep the bg-white on sections but maybe use backdrop-blur or make them slightly transparent like bg-white/90
html = html.replace('class="py-20 bg-white dark:bg-gray-900 relative transition-colors duration-300"', 'class="py-20 bg-transparent relative transition-colors duration-300"')
html = html.replace('class="py-20 bg-white dark:bg-gray-900 transition-colors duration-300"', 'class="py-20 bg-transparent transition-colors duration-300"')

# Make Prijzen section also slightly transparent or transparent
html = html.replace('class="py-20 bg-gray-50 dark:bg-gray-800 slant-top"', 'class="py-20 bg-gray-50/80 dark:bg-gray-800/80 backdrop-blur-sm slant-top"')

with open('/Users/matthias/Downloads/tt-clinics-website/index.html', 'w') as f:
    f.write(html)
