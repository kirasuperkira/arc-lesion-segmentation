#!/usr/bin/env bash
# Restore a pg_dump backup (created by db/backup.sh) into a clean database.
#
# Usage:
#   ./db/restore.sh db/backups/arc_lesion_20260713_120000.dump
#   DATABASE_URL=postgresql://user:pass@host:5432/arc_lesion ./db/restore.sh <file>
#
# WARNING: this drops and recreates all objects in the target schema
# before restoring. Do not run against a database you care about
# without a fresh backup first.

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <backup_file.dump>" >&2
    exit 1
fi

BACKUP_FILE="$1"
DSN="${DATABASE_URL:-postgresql://postgres:postgres@localhost:5432/arc_lesion}"

if [[ ! -f "${BACKUP_FILE}" ]]; then
    echo "Backup file not found: ${BACKUP_FILE}" >&2
    exit 1
fi

echo "Restoring ${BACKUP_FILE} into ${DSN%%@*}@..."
pg_restore --clean --if-exists --no-owner --dbname="${DSN}" "${BACKUP_FILE}"

echo "Restore complete."
