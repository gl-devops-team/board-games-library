from rest_framework.decorators import api_view
from rest_framework.response import Response

from games.utils import get_games_from_xlsx

SHEET_NAME = "Wroclaw_list of boardgames.xlsx"


@api_view(["GET"])
def game_list(request):
    """
    Retrieve a list of board games from an Excel file.

    Returns:
        200 OK: A JSON array of board games loaded from
        'Wroclaw_list of boardgames.xlsx'.
    """
    games = get_games_from_xlsx(SHEET_NAME)
    return Response(games)
