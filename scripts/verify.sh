#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <archive_file> <checksum_file>"
    exit 2
fi

ARCHIVE="$1"
CHECKSUM_FILE="$2"

if [ ! -f "$ARCHIVE" ]; then
    echo "ERROR: Archive file not found!"
    exit 3
fi

if [ ! -f "$CHECKSUM_FILE" ]; then
    echo "ERROR: Checksum file not found!"
    exit 3
fi

EXPECTED=$(awk 'NR==1 {print $1}' "$CHECKSUM_FILE")

if ! echo "$EXPECTED" | grep -Eq '^[a-fA-F0-9]{64}$'; then
    echo "ERROR: Invalid checksum format!"
    exit 3
fi

ACTUAL=$(sha256sum "$ARCHIVE" | awk '{print $1}')

echo "Archive: $ARCHIVE"
echo "Expected SHA-256: $EXPECTED"
echo "Actual SHA-256:   $ACTUAL"

if [ "$EXPECTED" = "$ACTUAL" ]; then
    echo "SUCCESS: Archive integrity verified."
    exit 0
else
    echo "ERROR: Archive integrity verification failed!"
    exit 4
fi
