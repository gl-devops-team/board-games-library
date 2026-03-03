from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.conf import settings
import os

from games.utils import get_games_from_xlsx

FILE_NAME = "Wroclaw_list of boardgames.xlsx"

@api_view(["GET"])
def game_list(request):
    file_path = os.path.join(settings.BASE_DIR, FILE_NAME)
    games = get_games_from_xlsx(file_path)
    return Response(games)
