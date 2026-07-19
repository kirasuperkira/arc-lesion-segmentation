set -euo pipefail

DSN="${DATABASE_URL:-postgresql://postgres:postgres@localhost:5432/arc_lesion}"
BACKUP_DIR="$(dirname "$0")/backups"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_FILE="${BACKUP_DIR}/arc_lesion_${TIMESTAMP}.dump"

mkdir -p "${BACKUP_DIR}"
echo "Backing up ${DSN%%@*}@... -> ${BACKUP_FILE}"
pg_dump --format=custom --file="${BACKUP_FILE}" "${DSN}"
echo "Backup complete: ${BACKUP_FILE} ($(du -h "${BACKUP_FILE}" | cut -f1))"