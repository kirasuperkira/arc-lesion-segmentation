import argparse
import csv
import os
import sys
import psycopg2

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--csv",
        default="results/batch_results.csv",
        help="Path to the batch_results.csv file",
    )
    parser.add_argument(
        "--dsn",
        default=os.environ.get(
            "DATABASE_URL", "postgresql://postgres:postgres@localhost:5432/arc_lesion"
        ),
        help="PostgreSQL connection string",
    )
    parser.add_argument(
        "--algorithm-version",
        default="threshold-p95-v1",
        help="Label recorded in processing_runs.algorithm_version",
    )
    return parser.parse_args()

def main() -> int:
    args = parse_args()

    if not os.path.exists(args.csv):
        print(f"CSV file not found: {args.csv}", file=sys.stderr)
        return 1

    conn = psycopg2.connect(args.dsn)
    conn.autocommit = False
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO processing_runs (algorithm_version, started_at, finished_at, status)
                VALUES (%s, now(), now(), 'completed')
                RETURNING id
                """,
                (args.algorithm_version,),
            )
            run_id = cur.fetchone()[0]

            inserted = 0
            with open(args.csv, newline="", encoding="utf-8") as f:
                reader = csv.DictReader(f)
                for row in reader:
                    cur.execute(
                        """
                        INSERT INTO participants
                            (subject_code, dice_score, lesion_volume_gt, lesion_volume_auto, run_id)
                        VALUES (%s, %s, %s, %s, %s)
                        ON CONFLICT (subject_code) DO UPDATE SET
                            dice_score = EXCLUDED.dice_score,
                            lesion_volume_gt = EXCLUDED.lesion_volume_gt,
                            lesion_volume_auto = EXCLUDED.lesion_volume_auto,
                            run_id = EXCLUDED.run_id,
                            processed_at = now()
                        """,
                        (
                            row["Subject"],
                            float(row["Dice"]),
                            int(row["Vol_GT"]),
                            int(row["Vol_Auto"]),
                            run_id,
                        ),
                    )
                    inserted += 1

        conn.commit()
        print(f"Loaded {inserted} participants into run_id={run_id}.")
        return 0
    except Exception as exc:
        conn.rollback()
        print(f"Seed failed, rolled back: {exc}", file=sys.stderr)
        return 1
    finally:
        conn.close()

if __name__ == "__main__":
    raise SystemExit(main())