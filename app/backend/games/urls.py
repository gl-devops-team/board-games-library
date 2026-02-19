# # games/urls.py
# from django.urls import path

# from games import views

# urlpatterns = [
#     path("", views.game_list, name="game-list"),
# ]

from django.urls import path

from games.views import game_list

urlpatterns = [
    path('games/', game_list, name="game-list"),
]
