#!/usr/bin/env bash
# tests/make_fixtures_restore.sh  (pemilik: Naufal)
# Membuat data uji untuk TC-R1..R4 (bagian restore). Aman dijalankan berulang.
# Pemakaian: tests/make_fixtures_restore.sh [DIR_FIXTURE_ABSOLUT]
# Exit: 0 sukses | 1 gagal membuat/memeriksa fixture | 2 parameter tidak valid
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
FIX_DIR="${1:-$REPO_DIR/data/fixtures_restore}"

die()  { echo "[GAGAL] $*" >&2; exit 1; }
info() { echo "[INFO]  $*"; }

# Penjaga: hanya boleh menghapus path absolut yang berakhiran /fixtures_restore
case "$FIX_DIR" in
  /*/fixtures_restore) ;;
  *) echo "[GAGAL] DIR_FIXTURE harus path absolut berakhiran /fixtures_restore: $FIX_DIR" >&2; exit 2 ;;
esac

# --- Tahap A: data dummy -------------------------------------------------
info "membersihkan dan membuat $FIX_DIR"
rm -rf -- "${FIX_DIR:?}"
SRC="$FIX_DIR/sumber/dokumen_uji"
mkdir -p -- "$SRC/sub" || die "tidak bisa membuat $SRC"

printf 'isi A\n' > "$SRC/laporan keuangan.txt"
printf 'isi B\n' > "$SRC/sub/catatan.txt"
: > "$SRC/kosong.txt"
printf 'ünïcödé\n' > "$SRC/unicode_é.txt"
info "data dummy dibuat: $(find "$SRC" -type f | wc -l) berkas"
