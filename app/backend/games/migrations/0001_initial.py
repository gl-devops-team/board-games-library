from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = []

    operations = [
        migrations.CreateModel(
            name="BoardGame",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("name", models.CharField(db_index=True, max_length=200)),
                ("min_players", models.PositiveSmallIntegerField()),
                ("max_players", models.PositiveSmallIntegerField()),
                ("game_time_minutes", models.PositiveSmallIntegerField()),
                ("category", models.CharField(db_index=True, max_length=100)),
                ("image_url", models.URLField(max_length=500)),
            ],
        ),
    ]
