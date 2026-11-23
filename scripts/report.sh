#!/usr/bin/env bash
set -u

# Laporan backup - Rania Lionar
# Pemakaian: ./scripts/report.sh <archive_file> <checksum_file>

if [ "$#" -ne 2 ]; then
    echo "Pemakaian: $0 <archive_file> <checksum_file>" >&2
    exit 2
fi

ARCHIVE="$1"
CHECKSUM_FILE="$2"
REPORT_DIR="${REPORT_DIR:-output}"
REPORT_FILE="$REPORT_DIR/laporan.txt"
VERIFY_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/verify.sh"
REPORT_LABEL="${REPORT_LABEL:-HASIL BACKUP}"
BACKUP_TIME="$(date '+%Y-%m-%d %H:%M:%S %Z')"

mkdir -p "$REPORT_DIR"

if [ -x "$VERIFY_SCRIPT" ]; then
    VERIFY_OUTPUT=$("$VERIFY_SCRIPT" "$ARCHIVE" "$CHECKSUM_FILE" 2>&1)
    VERIFY_EXIT=$?
else
    VERIFY_OUTPUT="ERROR: Script verifikasi tidak ditemukan."
    VERIFY_EXIT=3
fi

if [ "$VERIFY_EXIT" -eq 0 ]; then
    VERIFY_STATUS="VALID"
else
    VERIFY_STATUS="TIDAK VALID / GAGAL"
fi

{
    echo "======================================"
    echo "LAPORAN BACKUP"
    echo "Nama: Rania Lionar"
    echo "Jenis laporan: $REPORT_LABEL"
    echo "======================================"
    echo "Waktu backup: $BACKUP_TIME"
    echo "Nama arsip: $(basename "$ARCHIVE")"
    echo "Lokasi arsip: $ARCHIVE"
    echo "File checksum: $CHECKSUM_FILE"
    echo "Hasil verifikasi: $VERIFY_STATUS"
    echo ""
    echo "Detail verifikasi:"
    echo "$VERIFY_OUTPUT"
    echo "======================================"
} > "$REPORT_FILE"

echo "Laporan berhasil dibuat: $REPORT_FILE"
echo "Hasil verifikasi: $VERIFY_STATUS"
