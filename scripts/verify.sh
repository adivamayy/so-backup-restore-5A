#!/bin/bash
# verify.sh - Verifikasi integritas arsip backup dengan SHA-256
# Pemakaian    : ./scripts/verify.sh <archive_file> [checksum_file]
#                checksum_file default = <archive_file>.sha256
#                (format sha256sum: "<hash>  <nama_arsip>")
# Exit status  : 0 = checksum cocok (arsip utuh)
#                2 = parameter salah / berkas tidak ditemukan atau tidak terbaca
#                4 = checksum berbeda atau format berkas checksum tidak valid

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 <archive_file> [checksum_file]" >&2
    exit 2
fi

ARCHIVE="$1"
CHECKSUM_FILE="${2:-$1.sha256}"

if [ ! -f "$ARCHIVE" ] || [ ! -r "$ARCHIVE" ]; then
    echo "ERROR: Archive file not found or not readable: $ARCHIVE" >&2
    exit 2
fi

if [ ! -f "$CHECKSUM_FILE" ] || [ ! -r "$CHECKSUM_FILE" ]; then
    echo "ERROR: Checksum file not found or not readable: $CHECKSUM_FILE" >&2
    exit 2
fi

EXPECTED=$(awk 'NR==1 {print tolower($1)}' "$CHECKSUM_FILE")

if ! echo "$EXPECTED" | grep -Eq '^[a-f0-9]{64}$'; then
    echo "ERROR: Invalid checksum format in $CHECKSUM_FILE" >&2
    echo "RESULT: FAILED"
    exit 4
fi

if ! HASH_OUTPUT=$(sha256sum -- "$ARCHIVE"); then
    echo "ERROR: Failed to calculate checksum" >&2
    exit 2
fi
ACTUAL="${HASH_OUTPUT%% *}"

echo "Archive: $ARCHIVE"
echo "Expected SHA-256: $EXPECTED"
echo "Actual SHA-256:   $ACTUAL"

if [ "$EXPECTED" = "$ACTUAL" ]; then
    echo "SUCCESS: Archive integrity verified."
    echo "RESULT: OK"
    exit 0
else
    echo "ERROR: Archive integrity verification failed!" >&2
    echo "RESULT: FAILED"
    exit 4
fi
