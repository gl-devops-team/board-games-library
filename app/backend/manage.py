#!/usr/bin/env python
"""
Django command-line utility for administrative tasks.

This file serves as the entry point for Django management commands.
It allows execution of commands such as:

- runserver
- migrate
- makemigrations
- createsuperuser
- collectstatic

The script sets the default Django settings module and delegates
command execution to Django's internal management framework.
"""

import os
import sys


def main():
    """
    Execute Django administrative commands.

    Responsibilities:
    - Set the default DJANGO_SETTINGS_MODULE environment variable
    - Import Django's command execution utility
    - Forward command-line arguments to Django

    Raises:
        ImportError: If Django is not installed or not available
                     in the current Python environment.
    """

    # Set the default Django settings module for the project.
    # This tells Django which settings configuration to use.
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "boardgames.settings")

    try:
        # Import Django's command-line execution function.
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        # Raised if Django is not installed or virtual environment
        # is not activated.
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc

    # Execute the management command passed via CLI arguments.
    execute_from_command_line(sys.argv)


if __name__ == "__main__":
    """
    Entry point check.

    Ensures that main() runs only when this file is executed
    directly (not when imported as a module).
    """
    main()