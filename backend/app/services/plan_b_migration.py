"""Idempotent SQLite/Postgres-safe Plan B schema migration."""

from sqlalchemy import inspect, text

from app.database import engine


def migrate_owner_phone_column() -> None:
    """Add the nullable owner_phone column for pre-existing farms tables."""
    inspector = inspect(engine)
    if "farms" not in inspector.get_table_names():
        return

    columns = {column["name"] for column in inspector.get_columns("farms")}
    with engine.begin() as connection:
        if "owner_phone" not in columns:
            connection.execute(
                text("ALTER TABLE farms ADD COLUMN owner_phone VARCHAR(20)")
            )
        connection.execute(
            text(
                "CREATE INDEX IF NOT EXISTS ix_farms_owner_phone "
                "ON farms (owner_phone)"
            )
        )
