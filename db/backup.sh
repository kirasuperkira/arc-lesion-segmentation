#!/usr/bin/env bash
# Create a timestamped pg_dump backup of the arc_lesion database.
#
# Usage:
#   ./db/backup.sh
#   DATABASE_URL=postgresql://user:pass@host:5432/arc_lesion ./db/backup.sh
#
# Output: db/backups/arc_lesion_YYYYmmdd_HHMMSS.dump (custom format,
# restorable with pg_restore / db/restore.sh)

set -euo pipefail

DSN="${DATABASE_URL:-postgresql://postgres:postgres@localhost:5432/arc_lesion}"
BACKUP_DIR="$(dirname "$0")/backups"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_FILE="${BACKUP_DIR}/arc_lesion_${TIMESTAMP}.dump"

mkdir -p "${BACKUP_DIR}"

echo "Backing up ${DSN%%@*}@... -> ${BACKUP_FILE}"
pg_dump --format=custom --file="${BACKUP_FILE}" "${DSN}"

echo "Backup complete: ${BACKUP_FILE} ($(du -h "${BACKUP_FILE}" | cut -f1))"
