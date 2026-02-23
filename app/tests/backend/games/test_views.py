from unittest.mock import patch

from django.urls import reverse


@patch("games.views.get_games_from_xlsx")
def test_game_list_view(mock_get_games_from_xlsx, client):
    """This test verifies that:
    - The game_list view calls the get_games_from_xlsx function to retrieve game data.
    - The view renders the correct template with the expected context data.
    """
    # Mock the return value of get_games_from_xlsx
    mock_get_games_from_xlsx.return_value = [
        {
            "name": "Catan",
            "players": "3-4",
            "time": "1:00",
            "description": "Strategy",
            "image_url": "https://example.com/catan.jpg",
        },
        {
            "name": "Monopoly",
            "players": "2-6",
            "time": "2:00",
            "description": "Family",
            "image_url": "https://example.com/monopoly.jpg",
        },
    ]

    url = reverse("game-list")
    response = client.get(url)

    # Check if get_games_from_xlsx was called once
    mock_get_games_from_xlsx.assert_called_once_with("Wroclaw_list of boardgames.xlsx")

    # Check if the response is 200 OK
    assert response.status_code == 200

    # Check if the context contains the expected games data
    assert response.data == mock_get_games_from_xlsx.return_value
