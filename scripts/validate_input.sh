#!/usr/bin/env bash
# Validasi sumber & parameter backup.
# Exit: 0 = valid | 2 = sumber/parameter tidak valid (lihat pesan & log)
LOG_FILE="${LOG_FILE:-logs/validasi.log}"

log() {
  mkdir -p "$(dirname "$LOG_FILE")"
  echo "$(date '+%F %T') [$1] $2" >> "$LOG_FILE"
}

fail() {
  echo "ERROR: $1" >&2
  log ERROR "$1"
  exit 2
}

[ "$#" -eq 1 ] || fail "parameter salah. Pemakaian: $0 <direktori_sumber>"
src="$1"

[ -e "$src" ] || fail "sumber tidak tersedia: $src"
[ -d "$src" ] || fail "sumber bukan direktori: $src"
[ -r "$src" ] && [ -x "$src" ] || fail "sumber tidak dapat dibaca (permission): $src"
[ -n "$(ls -A "$src")" ] || fail "sumber kosong: $src"

echo "OK: sumber valid ($src)"
log INFO "sumber valid: $src"
exit 0
