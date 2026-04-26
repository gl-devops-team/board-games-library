from django.db import models


class BoardGame(models.Model):
    name = models.CharField(max_length=200, db_index=True)
    min_players = models.PositiveSmallIntegerField()
    max_players = models.PositiveSmallIntegerField()
    game_time_minutes = models.PositiveSmallIntegerField()
    category = models.CharField(max_length=100, db_index=True)
    image_url = models.URLField(max_length=500)

    def __str__(self):
        return self.name
