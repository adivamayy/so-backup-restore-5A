#!/usr/bin/env bash
# Kerangka backup.sh (bagian Rania: lock, log, laporan)
# Pemakaian: ./scripts/backup.sh <direktori_sumber> <direktori_tujuan>
LOCK_FILE="${LOCK_FILE:-/tmp/backup-5A.lock}"
LOG_DIR="${LOG_DIR:-logs}"; mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/backup_$(date +%Y%m%d).log"

log() { local lvl=$1; shift
  printf '%s [%s] [pid %d] %s\n' "$(date '+%F %T')" "$lvl" "$$" "$*" | tee -a "$LOG_FILE" >&2; }

acquire_lock() {
  exec 9>"$LOCK_FILE" || { log ERROR "Tidak bisa membuka lock file"; exit 6; }
  if ! flock -n 9; then
    log ERROR "Backup lain sedang berjalan (lock: $LOCK_FILE)"
    exit 6
  fi
  log INFO "Lock didapat"
}

if [ $# -ne 2 ]; then echo "Pemakaian: $0 <sumber> <tujuan>" >&2; exit 1; fi
SRC=$1; DEST=$2

acquire_lock
log INFO "Mulai backup $SRC -> $DEST"
sleep "${BACKUP_TEST_DELAY:-0}"      # jeda uji di dalam critical section
log INFO "Selesai (kerangka)"
exit 0
