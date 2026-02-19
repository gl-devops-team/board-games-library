from rest_framework.decorators import api_view
from rest_framework.response import Response
from games.utils import get_games_from_xlsx

SHEET_NAME = "Wroclaw_list of boardgames.xlsx"

@api_view(['GET'])
def game_list(request):
    games = get_games_from_xlsx(SHEET_NAME)
    return Response(games)