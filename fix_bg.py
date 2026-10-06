import re

with open('/Users/matthias/Downloads/tt-clinics-website/index.html', 'r') as f:
    html = f.read()

# Remove the broken background div
bg_start = "<!-- Abstract Table Tennis Background -->"
bg_end = "</div>"
start_idx = html.find(bg_start)
if start_idx != -1:
    end_idx = html.find(bg_end, start_idx) + len(bg_end)
    html = html[:start_idx] + html[end_idx:]

# Let's add a clear, well-designed repeating pattern of a ping pong table / paddles to the body via CSS in the head
style_addition = """
    <style>
        .table-pattern {
            background-color: transparent;
            background-image: url("data:image/svg+xml,%3Csvg width='120' height='120' viewBox='0 0 120 120' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg stroke='%23FF6B00' stroke-width='2' stroke-opacity='0.08' transform='rotate(15 60 60)'%3E%3Crect x='30' y='20' width='60' height='80' rx='2'/%3E%3Cline x1='30' y1='60' x2='90' y2='60'/%3E%3Cline x1='60' y1='20' x2='60' y2='100'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
        }
        .dark .table-pattern {
            background-image: url("data:image/svg+xml,%3Csvg width='120' height='120' viewBox='0 0 120 120' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg stroke='%23FFFFFF' stroke-width='2' stroke-opacity='0.04' transform='rotate(15 60 60)'%3E%3Crect x='30' y='20' width='60' height='80' rx='2'/%3E%3Cline x1='30' y1='60' x2='90' y2='60'/%3E%3Cline x1='60' y1='20' x2='60' y2='100'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
        }
    </style>
"""

# Insert style into head
html = html.replace('</head>', style_addition + '\n</head>')

# Add table-pattern class to body
html = html.replace('<body class="bg-white dark:bg-gray-900 text-tt-black dark:text-gray-100 font-inter transition-colors duration-300">', '<body class="bg-white dark:bg-gray-900 text-tt-black dark:text-gray-100 font-inter transition-colors duration-300 table-pattern">')

# Restore the solid backgrounds on sections so text is actually readable over the pattern
html = html.replace('class="py-20 bg-transparent relative transition-colors duration-300"', 'class="py-20 bg-white/90 dark:bg-gray-900/90 relative transition-colors duration-300"')
html = html.replace('class="py-20 bg-transparent transition-colors duration-300"', 'class="py-20 bg-white/90 dark:bg-gray-900/90 transition-colors duration-300"')

with open('/Users/matthias/Downloads/tt-clinics-website/index.html', 'w') as f:
    f.write(html)
