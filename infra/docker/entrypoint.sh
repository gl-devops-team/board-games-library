#!/bin/sh
set -e

python manage.py migrate --noinput
python manage.py loaddata board_games

exec "$@"
