from django.shortcuts import render
from .utils import get_games_from_xlsx

def game_list(request):
    games = get_games_from_xlsx("Wroclaw_list of boardgames.xlsx")
    return render(request, 'games/game_list.html', {'games': games})
