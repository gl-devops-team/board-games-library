"""
Django application configuration for the "games" app.

This module defines the AppConfig class, which Django uses to:
- Configure application metadata
- Register the app with the project
- Set default behaviors such as auto-generated primary key types
"""

from django.apps import AppConfig


class GamesConfig(AppConfig):
    """
    Configuration class for the games application.

    Attributes:
        default_auto_field (str):
            Specifies the default type for automatically created primary keys.
            Here, BigAutoField is used for large integer primary keys.
        
        name (str):
            The full Python path to the application (used by Django internally).
    """

    # Default type for auto-generated primary keys
    default_auto_field = "django.db.models.BigAutoField"

    # Application name
    name = "games"