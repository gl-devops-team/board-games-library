"""
URL configuration for the games application.

This module defines URL routing patterns for the games API.
Each route maps an HTTP endpoint to a corresponding view function.
"""

# Third-party imports
from django.urls import path

# Local application imports
from games.views import game_list


# List of URL patterns for this Django app.
# These patterns determine how incoming HTTP requests
# are routed to view functions.
urlpatterns = [
    path(
        "games/",
        game_list,
        name="game-list",
    ),
]