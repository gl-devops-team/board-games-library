"""
Django admin configuration for the games application.

This module registers models with the Django admin site,
allowing administrators to view, add, edit, and delete
records via the admin interface.

By default, no models are registered. You can register
models here using `admin.site.register(ModelName)`.
"""

from django.contrib import admin  # noqa: F401

# Example model registration (uncomment and replace with actual models):
# from .models import Game
#
# @admin.register(Game)
# class GameAdmin(admin.ModelAdmin):
#     """
#     Admin interface configuration for the Game model.
#
#     Attributes:
#         list_display (tuple): Fields to display in the list view.
#         search_fields (tuple): Fields to enable search functionality.
#         list_filter (tuple): Fields to filter by in the sidebar.
#     """
#     list_display = ('name', 'players', 'time', 'category')
#     search_fields = ('name', 'category')
#     list_filter = ('category',)