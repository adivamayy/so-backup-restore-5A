#!/usr/bin/env bash
# tests/test_restore.sh  (pemilik: Naufal)
# Menjalankan TC-R1..R6 untuk scripts/restore.sh dan mencetak LULUS/GAGAL.
# Exit 0 hanya jika tidak ada yang GAGAL.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
R="$REPO_DIR/scripts/restore.sh"
FIX="$REPO_DIR/data/fixtures_restore"
OUT=$(mktemp -d) || exit 1
export LOG_DIR="$OUT/logs"          # log uji tidak mengotori logs/ proyek
trap 'chmod -R u+w "$OUT" 2>/dev/null; rm -rf -- "${OUT:?}"' EXIT

"$REPO_DIR/tests/make_fixtures_restore.sh" >/dev/null || { echo "GAGAL membuat fixture"; exit 1; }

pass=0; fail=0; skip=0
lulus() { echo "LULUS  $1"; pass=$((pass+1)); }
gagal() { echo "GAGAL  $1"; fail=$((fail+1)); }
kosong() { [ -z "$(ls -A "$1" 2>/dev/null)" ]; }

# jalankan <id> <exit_diharapkan> <perintah...> : hasil stdout di $OUT/stdout.txt
jalankan() {
  local id=$1 want=$2; shift 2
  "$@" >"$OUT/stdout.txt" 2>"$OUT/stderr.txt"; local got=$?
  if [ "$got" -eq "$want" ]; then lulus "$id (exit $got)"; else gagal "$id (harap exit $want, dapat $got)"; fi
}

# TC-R1: arsip valid dipulihkan dan isinya identik dengan sumber
jalankan TC-R1 0 "$R" "$FIX/valid.tar.gz" "$OUT/r1"
final=$(cat "$OUT/stdout.txt")
if [ -d "$final" ] && diff -r "$FIX/sumber/dokumen_uji" "$final/dokumen_uji" >/dev/null 2>&1; then
  lulus "TC-R1 isi hasil restore identik dengan sumber (diff -r)"
else gagal "TC-R1 isi hasil restore berbeda dari sumber"; fi

# TC-R2/R3/R4: arsip bermasalah ditolak (exit 5) dan tidak meninggalkan sisa
for kasus in "TC-R2 rusak_checksum_lama" "TC-R3 rusak_checksum_baru" "TC-R4 tanpa_checksum"; do
  set -- $kasus; id=$1; nama=$2
  jalankan "$id" 5 "$R" "$FIX/$nama.tar.gz" "$OUT/$id"
  if kosong "$OUT/$id"; then lulus "$id tujuan bersih (tidak ada hasil palsu/sisa)"
  else gagal "$id ada sisa di tujuan: $(ls -A "$OUT/$id" | tr '\n' ' ')"; fi
done

# TC-R5: parameter salah / arsip tidak ada
jalankan TC-R5a 2 "$R" "$OUT/tidak_ada.tar.gz" "$OUT/r5"
jalankan TC-R5b 2 "$R"

# TC-R6: tujuan tidak dapat ditulis (butuh akun non-root)
if [ "$(id -u)" -eq 0 ]; then
  echo "LEWATI TC-R6 (root selalu bisa menulis; jalankan sebagai akun biasa)"; skip=$((skip+1))
else
  mkdir "$OUT/r6" && chmod a-w "$OUT/r6"
  jalankan TC-R6 3 "$R" "$FIX/valid.tar.gz" "$OUT/r6"
  chmod u+w "$OUT/r6"
fi

echo "---- ringkasan: $pass lulus, $fail gagal, $skip dilewati"
[ "$fail" -eq 0 ]
