from django.urls import reverse, resolve

from games.views import game_list


def test_game_list_url_resolves():
    """This test verifies that the URL pattern
      for the game list view is correctly defined and resolves to the expected view function."""
    assert reverse("game-list") == "/games/"
    assert resolve("/games/").func == game_list
