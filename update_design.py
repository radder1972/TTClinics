import re

with open('/Users/matthias/Downloads/tt-clinics-website/index.html', 'r') as f:
    html = f.read()

# 1. Add Favicon and Dark Mode config
head_end = "</head>"
favicon_and_config = """    <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><circle cx='50' cy='50' r='40' fill='%23FF6B00'/></svg>">
    <script>
        tailwind.config.darkMode = 'class';
    </script>
</head>"""
html = html.replace(head_end, favicon_and_config)

# 2. Add Dark Mode classes to body
html = html.replace('<body class="bg-white text-tt-black font-inter">', '<body class="bg-white dark:bg-gray-900 text-tt-black dark:text-gray-100 font-inter transition-colors duration-300">')

# 3. Add Dark Mode toggle to navbar and dark mode classes
navbar_old = """<nav class="bg-white text-tt-black p-4 sticky top-0 z-50 shadow-sm border-b border-gray-200">"""
navbar_new = """<nav class="bg-white dark:bg-gray-900 text-tt-black dark:text-white p-4 sticky top-0 z-50 shadow-sm border-b border-gray-200 dark:border-gray-800 transition-colors duration-300">"""
html = html.replace(navbar_old, navbar_new)

logo_old = """<div class="logo font-montserrat text-3xl font-black italic flex items-center gap-3 tracking-tighter">
                <img src="images/logo.jpg" alt="TT Clinics Logo" class="h-16 w-auto mix-blend-multiply">
                <div class="text-tt-black"><span class="text-tt-orange">TT</span> CLINICS</div>
            </div>"""
logo_new = """<div class="logo font-montserrat text-3xl font-black italic flex items-center gap-3 tracking-tighter relative group cursor-pointer">
                <img src="images/logo.jpg" alt="TT Clinics Logo" class="h-16 w-auto dark:bg-white dark:p-1 dark:rounded-xl mix-blend-multiply dark:mix-blend-normal group-hover:scale-105 transition-transform duration-300">
                <div class="absolute w-3 h-3 bg-tt-orange rounded-full top-2 left-6 opacity-0 group-hover:opacity-100 group-hover:translate-x-12 group-hover:-translate-y-6 group-hover:scale-150 transition-all duration-500 ease-out z-10"></div>
                <div class="text-tt-black dark:text-white"><span class="text-tt-orange">TT</span> CLINICS</div>
            </div>"""
html = html.replace(logo_old, logo_new)

menu_links_old = """<ul class="flex space-x-6 font-semibold">
                <li><a href="#" class="hover:text-tt-orange transition-colors text-tt-black">Home</a></li>
                <li><a href="#" class="hover:text-tt-orange transition-colors text-tt-black">Clinics</a></li>
                <li><a href="#" class="hover:text-tt-orange transition-colors text-tt-black">Over Ons</a></li>
                <li><a href="#" class="hover:text-tt-orange transition-colors text-tt-black">Contact</a></li>
            </ul>"""
menu_links_new = """<ul class="flex space-x-6 font-semibold items-center">
                <li><a href="#" class="hover:text-tt-orange transition-colors text-tt-black dark:text-white">Home</a></li>
                <li><a href="#" class="hover:text-tt-orange transition-colors text-tt-black dark:text-white">Clinics</a></li>
                <li><a href="#" class="hover:text-tt-orange transition-colors text-tt-black dark:text-white">Over Ons</a></li>
                <li><a href="#" class="hover:text-tt-orange transition-colors text-tt-black dark:text-white">Contact</a></li>
                <li><button id="themeToggle" class="ml-4 p-2 bg-gray-100 dark:bg-gray-800 rounded-full hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors" title="Toggle Dark Mode">🌓</button></li>
            </ul>"""
html = html.replace(menu_links_old, menu_links_new)

# 4. Add btn-speed to buttons
html = html.replace('class="btn-primary', 'class="btn-primary btn-speed')
html = html.replace('class="bg-tt-orange hover:bg-orange-600 text-white font-bold py-3 px-8 rounded-full transition-all transform hover:scale-105 shadow-lg"', 'class="btn-speed bg-tt-orange hover:bg-orange-600 text-white font-bold py-3 px-8 rounded-full transition-all transform hover:scale-105 shadow-lg"')
html = html.replace('class="block w-full bg-tt-black hover:bg-gray-800 text-white font-bold py-3 rounded-full transition-colors"', 'class="block w-full bg-tt-black hover:bg-gray-800 text-white font-bold py-3 rounded-full transition-colors btn-speed"')
html = html.replace('class="block w-full bg-tt-orange hover:bg-orange-600 text-white font-bold py-3 rounded-full transition-colors text-center"', 'class="block w-full bg-tt-orange hover:bg-orange-600 text-white font-bold py-3 rounded-full transition-colors text-center btn-speed"')
html = html.replace('class="w-full bg-tt-orange hover:bg-orange-600 text-white font-bold py-3 rounded-lg transition-colors mt-4"', 'class="w-full bg-tt-orange hover:bg-orange-600 text-white font-bold py-3 rounded-lg transition-colors mt-4 btn-speed"')

# 5. Add slant transitions between sections
# Over Ons to Prijzen
html = html.replace('<section id="prijzen" class="py-20 bg-gray-50 border-t border-gray-200">', '<section id="prijzen" class="py-20 bg-gray-50 dark:bg-gray-800 slant-top">')
# Contact to Footer
html = html.replace('<footer class="bg-tt-black text-white py-12 border-t-8 border-tt-orange">', '<footer class="bg-tt-black text-white py-12 border-t-8 border-tt-orange slant-top-footer">')

# Make sections dark mode compatible
html = html.replace('class="py-20 bg-white relative"', 'class="py-20 bg-white dark:bg-gray-900 relative transition-colors duration-300"')
html = html.replace('class="feature-card relative bg-gray-50 p-8 shadow-md hover:shadow-xl transition-shadow overflow-hidden group"', 'class="feature-card relative bg-gray-50 dark:bg-gray-800 dark:border-gray-700 dark:border p-8 shadow-md hover:shadow-xl transition-all overflow-hidden group"')
html = html.replace('class="feature-card relative bg-tt-black text-white p-8 shadow-md hover:shadow-xl transition-shadow overflow-hidden group"', 'class="feature-card relative bg-tt-black dark:bg-black text-white p-8 shadow-md hover:shadow-xl transition-all overflow-hidden group"')
html = html.replace('class="py-20 bg-white"', 'class="py-20 bg-white dark:bg-gray-900 transition-colors duration-300"')
html = html.replace('class="bg-white p-8 rounded-xl border border-gray-200 shadow-sm hover:shadow-lg transition-shadow text-center flex flex-col"', 'class="bg-white dark:bg-gray-900 dark:border-gray-700 p-8 rounded-xl border border-gray-200 shadow-sm hover:shadow-lg transition-shadow text-center flex flex-col"')
html = html.replace('class="text-gray-500', 'class="text-gray-500 dark:text-gray-400')
html = html.replace('class="text-gray-600', 'class="text-gray-600 dark:text-gray-300')
html = html.replace('class="text-tt-black', 'class="text-tt-black dark:text-white')
html = html.replace('class="bg-gray-100 p-4 rounded-lg text-center flex-1"', 'class="bg-gray-100 dark:bg-gray-800 p-4 rounded-lg text-center flex-1"')
html = html.replace('class="bg-white rounded-2xl overflow-hidden shadow-2xl flex flex-col md:flex-row border border-gray-100"', 'class="bg-white dark:bg-gray-800 dark:border-gray-700 rounded-2xl overflow-hidden shadow-2xl flex flex-col md:flex-row border border-gray-100"')
html = html.replace('class="md:w-3/5 p-10 bg-white"', 'class="md:w-3/5 p-10 bg-white dark:bg-gray-800"')
html = html.replace('class="block text-sm font-medium text-gray-700 mb-1"', 'class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1"')
html = html.replace('bg-white p-1 rounded-lg', 'bg-white p-1 rounded-lg dark:bg-white')

# 6. Add JS for dark mode at the end of body
js_script = """
    <script>
        const toggleBtn = document.getElementById('themeToggle');
        toggleBtn.addEventListener('click', () => {
            document.documentElement.classList.toggle('dark');
        });
    </script>
</body>
"""
html = html.replace('</body>', js_script)

with open('/Users/matthias/Downloads/tt-clinics-website/index.html', 'w') as f:
    f.write(html)
