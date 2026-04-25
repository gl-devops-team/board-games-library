import pytest
from django.urls import reverse
from games.models import BoardGame


@pytest.mark.django_db
def test_game_list_returns_all_games(client):
    BoardGame.objects.create(
        name="Catan",
        min_players=3,
        max_players=4,
        game_time_minutes=60,
        category="Strategy",
        image_url="https://example.com/catan.jpg",
    )
    BoardGame.objects.create(
        name="Monopoly",
        min_players=2,
        max_players=6,
        game_time_minutes=120,
        category="Family",
        image_url="https://example.com/monopoly.jpg",
    )

    url = reverse("game-list")
    response = client.get(url)

    assert response.status_code == 200
    assert len(response.data) == 2


@pytest.mark.django_db
def test_game_list_returns_expected_fields(client):
    BoardGame.objects.create(
        name="Catan",
        min_players=3,
        max_players=4,
        game_time_minutes=60,
        category="Strategy",
        image_url="https://example.com/catan.jpg",
    )

    url = reverse("game-list")
    response = client.get(url)

    game = response.data[0]
    assert game["name"] == "Catan"
    assert game["min_players"] == 3
    assert game["max_players"] == 4
    assert game["game_time_minutes"] == 60
    assert game["category"] == "Strategy"
    assert game["image_url"] == "https://example.com/catan.jpg"


@pytest.mark.django_db
def test_game_list_returns_games_sorted_by_name(client):
    BoardGame.objects.create(
        name="Monopoly",
        min_players=2,
        max_players=6,
        game_time_minutes=120,
        category="Family",
        image_url="",
    )
    BoardGame.objects.create(
        name="Catan",
        min_players=3,
        max_players=4,
        game_time_minutes=60,
        category="Strategy",
        image_url="",
    )

    url = reverse("game-list")
    response = client.get(url)

    assert response.data[0]["name"] == "Catan"
    assert response.data[1]["name"] == "Monopoly"


@pytest.mark.django_db
def test_game_list_empty_database(client):
    url = reverse("game-list")
    response = client.get(url)

    assert response.status_code == 200
    assert response.data == []
