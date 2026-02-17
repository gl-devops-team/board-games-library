from django.shortcuts import render
from games.utils import get_games_from_xlsx

SHEET_NAME = "Wroclaw_list of boardgames.xlsx"

def game_list(request):
    games = get_games_from_xlsx(SHEET_NAME)
    return render(request, 'games/game_list.html', {'games': games})
