import pygsheets

gc = pygsheets.authorize(service_file='credentials.json')

sh = gc.open_by_key('ID_ARKUSZA')
wks = sh.sheet1  # pierwsza zakładka

data = wks.get_all_values()

import csv
with open('plik.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerows(data)

print("Plik CSV zapisany jako 'plik.csv'.")
