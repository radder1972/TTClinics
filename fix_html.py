import re

with open('/Users/matthias/Downloads/tt-clinics-website/index.html', 'r') as f:
    content = f.read()

# 1. Remove tt-red from config
content = re.sub(r"'tt-red': '#E53935',\s*", "", content)

# 2. Replace hover:bg-tt-red with hover:bg-orange-600
content = content.replace("hover:bg-tt-red", "hover:bg-orange-600")

# 3. Replace text-tt-red with text-tt-orange
content = content.replace("text-tt-red", "text-tt-orange")

# 4. Replace bg-tt-red in contact form with bg-tt-orange
content = content.replace("bg-tt-red", "bg-tt-orange")

# 5. Replace border-tt-red in footer with border-tt-orange
content = content.replace("border-tt-red", "border-tt-orange")

# 6. Redesign "Wat wij bieden" section to use swoosh styles
# Find the Wat wij bieden section
wat_wij_bieden_old = """            <h2 class="font-montserrat text-4xl font-black text-center italic mb-16 uppercase">Wat wij <span class="text-tt-orange">bieden</span></h2>
            
            <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
                <!-- Card 1 -->
                <div class="feature-card bg-gray-50 p-8 rounded-xl border-t-4 border-tt-orange shadow-md hover:shadow-xl transition-shadow">
                    <h3 class="font-montserrat text-2xl font-bold mb-4">Techniek Training</h3>
                    <p class="text-gray-600">Leer de perfecte slagen, voetenwerk en basistechnieken van ervaren trainers.</p>
                </div>
                
                <!-- Card 2 -->
                <div class="feature-card bg-gray-50 p-8 rounded-xl border-t-4 border-tt-black shadow-md hover:shadow-xl transition-shadow">
                    <h3 class="font-montserrat text-2xl font-bold mb-4">Tactisch Inzicht</h3>
                    <p class="text-gray-600">Begrijp het spel beter, leer wedstrijden lezen en ontwikkel je eigen winnende strategieën.</p>
                </div>
                
                <!-- Card 3 -->
                <div class="feature-card bg-gray-50 p-8 rounded-xl border-t-4 border-tt-orange shadow-md hover:shadow-xl transition-shadow">
                    <h3 class="font-montserrat text-2xl font-bold mb-4">Voor Elk Niveau</h3>
                    <p class="text-gray-600">Van beginners tot gevorderden, onze clinics worden op maat gemaakt voor jouw speelsterkte.</p>
                </div>
            </div>"""

wat_wij_bieden_new = """            <h2 class="font-montserrat text-4xl font-black text-center italic mb-16 uppercase">Wat wij <span class="text-tt-orange">bieden</span></h2>
            
            <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
                <!-- Dynamic Card 1 -->
                <div class="feature-card relative bg-gray-50 p-8 shadow-md hover:shadow-xl transition-shadow overflow-hidden group" style="border-radius: 0 40px 0 40px;">
                    <div class="absolute -right-10 -top-10 w-32 h-32 bg-tt-orange opacity-20 rounded-full group-hover:scale-150 transition-transform duration-500 ease-in-out"></div>
                    <div class="absolute right-0 top-0 w-16 h-16 border-t-4 border-r-4 border-tt-orange rounded-tr-[40px]"></div>
                    <h3 class="font-montserrat text-2xl font-black italic mb-4 relative z-10">Techniek <br><span class="text-tt-orange">Training</span></h3>
                    <p class="text-gray-600 relative z-10">Leer de perfecte slagen, voetenwerk en basistechnieken van ervaren trainers.</p>
                </div>
                
                <!-- Dynamic Card 2 -->
                <div class="feature-card relative bg-tt-black text-white p-8 shadow-md hover:shadow-xl transition-shadow overflow-hidden group" style="border-radius: 40px 0 40px 0;">
                    <div class="absolute -left-10 -bottom-10 w-32 h-32 bg-tt-orange opacity-20 rounded-full group-hover:scale-150 transition-transform duration-500 ease-in-out"></div>
                    <div class="absolute left-0 bottom-0 w-16 h-16 border-b-4 border-l-4 border-tt-orange rounded-bl-[40px]"></div>
                    <h3 class="font-montserrat text-2xl font-black italic mb-4 relative z-10">Tactisch <br><span class="text-tt-orange">Inzicht</span></h3>
                    <p class="text-gray-300 relative z-10">Begrijp het spel beter, leer wedstrijden lezen en ontwikkel je eigen winnende strategieën.</p>
                </div>
                
                <!-- Dynamic Card 3 -->
                <div class="feature-card relative bg-gray-50 p-8 shadow-md hover:shadow-xl transition-shadow overflow-hidden group" style="border-radius: 0 40px 0 40px;">
                    <div class="absolute -right-10 -top-10 w-32 h-32 bg-tt-orange opacity-20 rounded-full group-hover:scale-150 transition-transform duration-500 ease-in-out"></div>
                    <div class="absolute right-0 top-0 w-16 h-16 border-t-4 border-r-4 border-tt-orange rounded-tr-[40px]"></div>
                    <h3 class="font-montserrat text-2xl font-black italic mb-4 relative z-10">Voor Elk <br><span class="text-tt-orange">Niveau</span></h3>
                    <p class="text-gray-600 relative z-10">Van beginners tot gevorderden, onze clinics worden op maat gemaakt voor jouw speelsterkte.</p>
                </div>
            </div>"""

content = content.replace(wat_wij_bieden_old, wat_wij_bieden_new)

# Also fix the old text-tt-red that might not have been matched properly if it was in the old block.
# Actually I replaced text-tt-red globally above. So I should use the already replaced string for the search.
wat_wij_bieden_old_replaced = wat_wij_bieden_old.replace("text-tt-red", "text-tt-orange")
content = content.replace(wat_wij_bieden_old_replaced, wat_wij_bieden_new)

with open('/Users/matthias/Downloads/tt-clinics-website/index.html', 'w') as f:
    f.write(content)
