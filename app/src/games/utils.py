import requests
import csv
from io import StringIO

def get_games_from_sheet():
    SHEET_ID = '15fAZGzymIw-MYzVtYiNsJnihWuYDNnLc7NpQAor4W-Y'
    url = f'https://docs.google.com/spreadsheets/d/{SHEET_ID}/export?format=csv'
    response = requests.get(url)
    response.raise_for_status()

    csv_text = StringIO(response.text)
    reader = csv.DictReader(csv_text)

    games = []
    for row in reader:
        games.append({
            'name': row['Name'],
            'players': row['Number of players'],
            'time': row['Average game time [h:mm]'],
            'description': row['Category']
        })
    return games
