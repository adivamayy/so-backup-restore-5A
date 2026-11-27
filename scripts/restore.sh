#!/usr/bin/env bash
# scripts/restore.sh  (pemilik: Naufal)
# Memulihkan arsip backup ke direktori uji, HANYA setelah lolos verifikasi checksum
# dan pemeriksaan isi arsip.
# Pemakaian: scripts/restore.sh <arsip.tar.gz> <dir_restore> [berkas_checksum]
#            (berkas_checksum default: <arsip>.sha256)
# stdout saat sukses: path direktori hasil restore (satu baris)
# Exit: 0 sukses | 1 galat tak terduga | 2 parameter/arsip tidak valid
#       3 tujuan tidak dapat ditulis | 5 arsip rusak atau restore ditolak
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="${LOG_DIR:-$REPO_DIR/logs}"
LOG_FILE="${LOG_FILE:-$LOG_DIR/restore.log}"
VERIFY="$SCRIPT_DIR/verify.sh"

readonly EX_ERR=1 EX_PARAM=2 EX_DEST=3 EX_CORRUPT=5

# Log ke berkas dan ke stderr (stdout dipakai khusus untuk hasil).
log() {
  local lvl=$1; shift
  mkdir -p -- "$LOG_DIR" 2>/dev/null
  printf '%s [%s] [restore] %s\n' "$(date '+%F %T')" "$lvl" "$*" >> "$LOG_FILE" 2>/dev/null
  printf '[%s] %s\n' "$lvl" "$*" >&2
}
die() { local code=$1; shift; log ERROR "$*"; exit "$code"; }

# 1. Parameter dan arsip
{ [ $# -eq 2 ] || [ $# -eq 3 ]; } \
  || die "$EX_PARAM" "pemakaian: restore.sh <arsip.tar.gz> <dir_restore> [berkas_checksum]"
archive=$1
destdir=$2
checksum=${3:-$archive.sha256}
[ -f "$archive" ] && [ -r "$archive" ] || die "$EX_PARAM" "arsip tidak ada atau tidak terbaca: $archive"

# 2. Tujuan harus ada (atau bisa dibuat) dan bisa ditulis
mkdir -p -- "$destdir" 2>/dev/null
[ -d "$destdir" ] && [ -w "$destdir" ] || die "$EX_DEST" "tujuan tidak dapat ditulis: $destdir"

# 3. Gerbang integritas: tanpa checksum yang cocok, tidak ada restore
[ -f "$checksum" ] || die "$EX_CORRUPT" "berkas checksum tidak ada, restore ditolak: $checksum"
verify_out=$(bash "$VERIFY" "$archive" "$checksum" 2>&1); verify_rc=$?
[ "$verify_rc" -eq 0 ] || die "$EX_CORRUPT" "verifikasi checksum gagal (verify.sh exit $verify_rc), restore ditolak"

# 4. Gerbang struktur: arsip terbaca penuh dan tidak memuat path berbahaya
listing=$(tar -tzf "$archive" 2>/dev/null) || die "$EX_CORRUPT" "arsip tidak dapat dibaca penuh oleh tar"
if grep -Eq '(^/|(^|/)\.\.(/|$))' <<<"$listing"; then
  die "$EX_CORRUPT" "arsip memuat path berbahaya (absolut atau ..), restore ditolak"
fi

# 5. Ekstrak ke direktori sementara di filesystem yang sama dengan tujuan final
tmp=$(mktemp -d "$destdir/.restore_tmp.XXXXXX") || die "$EX_DEST" "gagal membuat direktori sementara di $destdir"
trap 'rm -rf -- "${tmp:?}"' EXIT
tar -xzf "$archive" -C "$tmp" --no-same-owner 2>/dev/null \
  || die "$EX_CORRUPT" "ekstraksi gagal, restore ditolak"

# 6. Publikasi atomik (rename), baru nyatakan berhasil
final="$destdir/restore_$(date +%Y%m%d_%H%M%S)_$$"
[ -e "$final" ] && die "$EX_ERR" "direktori hasil sudah ada: $final"
mv -- "$tmp" "$final" || die "$EX_ERR" "gagal memindahkan hasil restore ke $final"
trap - EXIT
log INFO "restore OK: $archive -> $final"
printf '%s\n' "$final"
exit 0
