#!/usr/bin/env bash
set -u

# backup otomatis - bagian rania lionar
# pemakaian: ./scripts/backup.sh <direktori_sumber> <direktori_tujuan>

lock_file="${LOCK_FILE:-/tmp/backup-5A.lock}"
log_dir="${LOG_DIR:-logs}"
report_dir="${REPORT_DIR:-output}"

mkdir -p "$log_dir"
log_file="$log_dir/backup_$(date +%Y%m%d).log"

log() {
    local level="$1"
    shift
    printf '%s [%s] [pid %d] %s\n' \
        "$(date '+%F %T')" "$level" "$$" "$*" | tee -a "$log_file" >&2
}

if [ "$#" -ne 2 ]; then
    echo "pemakaian: $0 <sumber> <tujuan>" >&2
    exit 1
fi

if [ ! -d "$1" ]; then
    log ERROR "Direktori sumber tidak ditemukan: $1"
    exit 2
fi

src="$(realpath "$1")"
dest_input="$2"

mkdir -p "$dest_input" || {
    log ERROR "Tidak bisa membuat direktori tujuan"
    exit 3
}

dest="$(realpath "$dest_input")"

case "$dest/" in
    "$src/"*)
        log ERROR "Direktori tujuan tidak boleh berada di dalam sumber"
        exit 3
        ;;
esac

exec 9>"$lock_file" || {
    log ERROR "Tidak bisa membuka lock file"
    exit 6
}

if ! flock -n 9; then
    log ERROR "Backup lain sedang berjalan"
    exit 6
fi

log INFO "Lock berhasil didapat"
log INFO "Memulai backup: $src"

timestamp="$(date +%Y%m%d_%H%M%S)"
archive_name="$(basename "$src")_$timestamp.tar.gz"
archive="$dest/$archive_name"
temp_archive="$archive.part.$$"

if ! tar -czf "$temp_archive" -C "$(dirname "$src")" "$(basename "$src")"; then
    rm -f "$temp_archive"
    log ERROR "Proses pembuatan arsip gagal"
    exit 5
fi

if ! mv "$temp_archive" "$archive"; then
    rm -f "$temp_archive"
    log ERROR "Gagal menyimpan arsip"
    exit 5
fi

checksum_file="$archive.sha256"

if ! sha256sum "$archive" > "$checksum_file"; then
    rm -f "$archive" "$checksum_file"
    log ERROR "Gagal membuat checksum"
    exit 5
fi

log INFO "Arsip berhasil dibuat: $archive"
log INFO "Checksum berhasil dibuat: $checksum_file"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -x "$script_dir/report.sh" ]; then
    if REPORT_DIR="$report_dir" "$script_dir/report.sh" "$archive" "$checksum_file"; then
        log INFO "Laporan backup berhasil diproses"
    else
        log ERROR "Pembuatan laporan gagal"
        exit 5
    fi
else
    log ERROR "Script report.sh tidak ditemukan atau tidak executable"
    exit 5
fi

log INFO "Backup selesai"
exit 0
