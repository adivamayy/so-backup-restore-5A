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

# --- Tahap B: arsip valid ------------------------------------------------
cd "$FIX_DIR" || die "tidak bisa masuk $FIX_DIR"
tar -czf valid.tar.gz -C sumber dokumen_uji || die "gagal membuat valid.tar.gz"
sha256sum valid.tar.gz > valid.tar.gz.sha256 || die "gagal membuat checksum valid"
cp valid.tar.gz tanpa_checksum.tar.gz || die "gagal menyalin tanpa_checksum"
info "arsip valid dibuat ($(wc -c < valid.tar.gz) byte)"

# --- Tahap C: arsip rusak ------------------------------------------------
half=$(( $(wc -c < valid.tar.gz) / 2 ))
head -c "$half" valid.tar.gz > rusak_checksum_lama.tar.gz || die "gagal memotong (lama)"
head -c "$half" valid.tar.gz > rusak_checksum_baru.tar.gz || die "gagal memotong (baru)"
old_hash=$(cut -d' ' -f1 valid.tar.gz.sha256)
printf '%s  %s\n' "$old_hash" "rusak_checksum_lama.tar.gz" > rusak_checksum_lama.tar.gz.sha256
sha256sum rusak_checksum_baru.tar.gz > rusak_checksum_baru.tar.gz.sha256 || die "gagal checksum baru"

# --- Tahap D: periksa bahwa fixture memang seperti yang diklaim ------------
sha256sum --status -c valid.tar.gz.sha256 \
  || die "valid.tar.gz seharusnya LOLOS checksum"
tar -tzf valid.tar.gz >/dev/null 2>&1 \
  || die "valid.tar.gz seharusnya terbaca penuh oleh tar"
if sha256sum --status -c rusak_checksum_lama.tar.gz.sha256 2>/dev/null; then
  die "rusak_checksum_lama seharusnya GAGAL checksum"
fi
sha256sum --status -c rusak_checksum_baru.tar.gz.sha256 \
  || die "rusak_checksum_baru seharusnya LOLOS checksum (itulah intinya)"
if tar -tzf rusak_checksum_baru.tar.gz >/dev/null 2>&1; then
  die "rusak_checksum_baru seharusnya GAGAL dibaca tar"
fi
[ ! -e tanpa_checksum.tar.gz.sha256 ] || die "tanpa_checksum seharusnya TIDAK punya .sha256"

info "semua fixture diperiksa dan sesuai rancangan:"
ls -1 "$FIX_DIR" | sed 's/^/        /'
exit 0
