from django.urls import resolve, reverse
from games.views import game_list


def test_game_list_url_resolves():
    """This test verifies that the URL pattern for the game list view
    is correctly defined and resolves to the expected view function."""
    assert reverse("game-list") == "/api/games/"
    assert resolve("/api/games/").func == game_list
