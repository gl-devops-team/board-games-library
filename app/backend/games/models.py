"""
Database models for the games application.

This module defines the Django ORM models representing
the main entities in the board games application.

Models define:
- Database table structure
- Field types
- Relationships (ForeignKey, ManyToMany, etc.)
- Validation and constraints
"""

from django.db import models  # noqa: F401

# Example model template (replace with actual models):
# class Game(models.Model):
#     """
#     Represents a board game in the application.
# 
#     Fields:
#         name (str): Name of the game.
#         players (str): Number of players (e.g., "2-4").
#         time (str): Average play time.
#         category (str): Game category or type.
#         image_url (str): URL to a game image (optional).
#     """
#     name = models.CharField(max_length=255)
#     players = models.CharField(max_length=50)
#     time = models.CharField(max_length=50)
#     category = models.CharField(max_length=100)
#     image_url = models.URLField(blank=True)
#
#     def __str__(self):
#         """Return the name of the game for admin and display purposes."""
#         return self.name