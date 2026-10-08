from datetime import datetime, timezone
from pathlib import Path

import pandas as pd
from sqlalchemy import text

from db import get_engine

RAW_DATA_DIRECTORY = Path(__file__).resolve().parent.parent / "data" / "raw"
RAW_SCHEMA = "raw"
ROWS_PER_INSERT_BATCH = 5000


def table_name_from_file(csv_path):
    table_name = csv_path.stem
    table_name = table_name.removeprefix("olist_")
    table_name = table_name.removesuffix("_dataset")
    return table_name


def load_csv_to_raw(csv_path, engine, loaded_at):
    table_name = table_name_from_file(csv_path)
    dataframe = pd.read_csv(csv_path, dtype=str, keep_default_na=False, na_values=[""])
    dataframe["_source_file"] = csv_path.name
    dataframe["_loaded_at"] = loaded_at

    with engine.begin() as connection:
        dataframe.to_sql(
            name=table_name,
            con=connection,
            schema=RAW_SCHEMA,
            if_exists="replace",
            index=False,
            method="multi",
            chunksize=ROWS_PER_INSERT_BATCH,
        )

    return table_name, len(dataframe)


def main():
    engine = get_engine()
    loaded_at = datetime.now(timezone.utc)

    with engine.begin() as connection:
        connection.execute(text(f"CREATE SCHEMA IF NOT EXISTS {RAW_SCHEMA}"))

    csv_paths = sorted(RAW_DATA_DIRECTORY.glob("*.csv"))
    if not csv_paths:
        raise FileNotFoundError(f"No CSV files found in {RAW_DATA_DIRECTORY}")

    for csv_path in csv_paths:
        table_name, row_count = load_csv_to_raw(csv_path, engine, loaded_at)
        print(f"Loaded {row_count:,} rows into {RAW_SCHEMA}.{table_name}")


if __name__ == "__main__":
    main()