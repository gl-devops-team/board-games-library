from django.conf import settings
from django.core.management.base import BaseCommand

from games.models import BoardGame
from games.utils import get_games_from_xlsx


def _parse_players(value: str) -> tuple[int, int]:
    """Parse '2-10' → (2, 10). 'x' means unlimited → stored as 99."""
    value = value.strip()
    if value == "-":
        return 1, 99
    if "-" in value:
        parts = value.split("-", 1)
        lo = int(parts[0])
        hi = 99 if parts[1].strip().lower() == "x" else int(parts[1])
        return lo, hi
    if value.endswith("+"):
        n = int(value[:-1])
        return n, 99
    if value.lower() == "x":
        return 1, 99
    n = int(value)
    return n, n


def _parse_time_minutes(value: str) -> int:
    """Parse '0:30' or '0:30:00' (Excel datetime.time) → minutes as integer. '-' → 0."""
    value = value.strip()
    if value == "-" or value == "":
        return 0
    parts = value.split(":")
    return int(parts[0]) * 60 + int(parts[1])


class Command(BaseCommand):
    help = "Import board games from the Excel spreadsheet into the database."

    def handle(self, *args, **options):
        xlsx_path = settings.BASE_DIR / "Wroclaw_list of boardgames.xlsx"
        games = get_games_from_xlsx(str(xlsx_path))

        created_count = 0
        updated_count = 0
        skipped_count = 0

        for raw in games:
            name = raw.get("name", "").strip()
            if not name:
                skipped_count += 1
                continue

            try:
                min_players, max_players = _parse_players(raw.get("players", "0"))
                game_time_minutes = _parse_time_minutes(raw.get("time", "0:00"))
            except (ValueError, AttributeError) as exc:
                self.stderr.write(f"Skipping '{name}': {exc}")
                skipped_count += 1
                continue

            _, created = BoardGame.objects.update_or_create(
                name=name,
                defaults={
                    "min_players": min_players,
                    "max_players": max_players,
                    "game_time_minutes": game_time_minutes,
                    "category": raw.get("description", "").strip(),
                    "image_url": raw.get("image_url", "").strip(),
                },
            )
            if created:
                created_count += 1
            else:
                updated_count += 1

        self.stdout.write(
            self.style.SUCCESS(
                f"Done: {created_count} created, "
                f"{updated_count} updated, {skipped_count} skipped."
            )
        )
