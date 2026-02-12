from django.shortcuts import render
from .utils import get_games_from_sheet

def game_list(request):
    games = get_games_from_sheet()
    return render(request, 'games/game_list.html', {'games': games})
