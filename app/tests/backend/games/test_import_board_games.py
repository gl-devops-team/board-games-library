from unittest.mock import patch

import pytest
from django.core.management import call_command

from games.models import BoardGame
from games.management.commands.import_board_games import _parse_players, _parse_time_minutes


def test_parse_players_range():
    assert _parse_players("2-10") == (2, 10)


def test_parse_players_single():
    assert _parse_players("4") == (4, 4)


def test_parse_players_plus():
    assert _parse_players("10+") == (10, 99)


def test_parse_time_minutes_zero():
    assert _parse_time_minutes("0:30") == 30


def test_parse_time_minutes_hours():
    assert _parse_time_minutes("1:30") == 90


def test_parse_time_minutes_full_hour():
    assert _parse_time_minutes("2:00") == 120


MOCK_GAMES = [
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


@pytest.mark.django_db
@patch("games.management.commands.import_board_games.get_games_from_xlsx", return_value=MOCK_GAMES)
def test_import_creates_games(mock_xlsx):
    call_command("import_board_games")

    assert BoardGame.objects.count() == 2
    catan = BoardGame.objects.get(name="Catan")
    assert catan.min_players == 3
    assert catan.max_players == 4
    assert catan.game_time_minutes == 60
    assert catan.category == "Strategy"


@pytest.mark.django_db
@patch("games.management.commands.import_board_games.get_games_from_xlsx", return_value=MOCK_GAMES)
def test_import_is_idempotent(mock_xlsx):
    call_command("import_board_games")
    call_command("import_board_games")

    assert BoardGame.objects.count() == 2


@pytest.mark.django_db
@patch(
    "games.management.commands.import_board_games.get_games_from_xlsx",
    return_value=[{"name": "", "players": "2-4", "time": "0:30", "description": "Family", "image_url": ""}],
)
def test_import_skips_empty_name(mock_xlsx):
    call_command("import_board_games")

    assert BoardGame.objects.count() == 0
