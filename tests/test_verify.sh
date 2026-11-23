
#!/usr/bin/env bash

cd "$(dirname "$0")/.." || exit 1

S="scripts/verify.sh"
T=$(mktemp -d)

trap 'rm -rf "$T"' EXIT

echo "Isi arsip untuk pengujian SHA-256" > "$T/archive.tar.gz"

sha256sum "$T/archive.tar.gz" > "$T/archive.tar.gz.sha256"

echo "======================================"
echo "PENGUJIAN VERIFIKASI SHA-256 - KHANSA"
echo "======================================"

echo
echo "== (+) Checksum cocok, harapan exit 0"

"$S" "$T/archive.tar.gz" "$T/archive.tar.gz.sha256"
STATUS=$?
echo "Exit: $STATUS"

if [ "$STATUS" -ne 0 ]; then
    echo "PENGUJIAN POSITIF: GAGAL"
    exit 1
fi

echo
echo "== (-) Checksum berbeda, harapan exit 4"

echo "Isi arsip diubah" >> "$T/archive.tar.gz"

"$S" "$T/archive.tar.gz" "$T/archive.tar.gz.sha256"
STATUS=$?
echo "Exit: $STATUS"

if [ "$STATUS" -ne 4 ]; then
    echo "PENGUJIAN NEGATIF: GAGAL"
    exit 1
fi

echo
echo "SEMUA PENGUJIAN BERHASIL"
exit 0
