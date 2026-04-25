from rest_framework.decorators import api_view
from rest_framework.response import Response

from games.models import BoardGame


@api_view(["GET"])
def game_list(request):
    games = list(
        BoardGame.objects.all()
        .order_by("name")
        .values(
            "name",
            "min_players",
            "max_players",
            "game_time_minutes",
            "category",
            "image_url",
        )  # noqa: E501
    )
    return Response(games)
