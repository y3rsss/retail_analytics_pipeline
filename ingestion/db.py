import os

from dotenv import load_dotenv
from sqlalchemy import URL, create_engine, text

load_dotenv()


def get_engine():
    connection_url = URL.create(
        drivername="postgresql+psycopg2",
        username=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD"),
        host=os.getenv("POSTGRES_HOST", "localhost"),
        port=int(os.getenv("POSTGRES_PORT", "5434")),
        database=os.getenv("POSTGRES_DB"),
    )
    return create_engine(connection_url)


if __name__ == "__main__":
    engine = get_engine()
    with engine.connect() as connection:
        postgres_version = connection.execute(text("SELECT version();")).scalar()
        print(f"Connected to: {postgres_version}")