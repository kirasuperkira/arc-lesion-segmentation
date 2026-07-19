import os
from typing import Any, Dict, List, Optional
import psycopg2
import psycopg2.extras

DATABASE_URL = os.environ.get(
    "DATABASE_URL", "postgresql://qa_readonly:change_me_in_prod@localhost:5432/arc_lesion"
)

def get_connection():
    return psycopg2.connect(DATABASE_URL)

def fetch_participants(limit: int = 50, offset: int = 0) -> List[Dict[str, Any]]:
    query = """
        SELECT subject_code, dice_score, lesion_volume_gt, lesion_volume_auto, processed_at
        FROM participants
        ORDER BY subject_code
        LIMIT %s OFFSET %s
    """
    with get_connection() as conn:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(query, (limit, offset))
            return [dict(row) for row in cur.fetchall()]

def fetch_participant(subject_code: str) -> Optional[Dict[str, Any]]:
    query = """
        SELECT subject_code, dice_score, lesion_volume_gt, lesion_volume_auto, processed_at
        FROM participants
        WHERE subject_code = %s
    """
    with get_connection() as conn:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(query, (subject_code,))
            row = cur.fetchone()
            return dict(row) if row else None

def fetch_stats() -> Dict[str, Any]:
    query = """
        SELECT
            COUNT(*)                    AS participants_count,
            ROUND(AVG(dice_score), 4)   AS avg_dice,
            MIN(dice_score)             AS min_dice,
            MAX(dice_score)             AS max_dice
        FROM participants
    """
    with get_connection() as conn:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(query)
            return dict(cur.fetchone())