# Exit status:
#   0 sukses
#   1 parameter salah / gagal lainnya (tar atau checksum)
#   2 sumber tidak tersedia / tidak terbaca
#   3 tujuan tidak dapat ditulis

LOG="${LOG:-logs/backup.log}"
mkdir -p "$(dirname "$LOG")"

log() { echo "$(date '+%F %T') [archive] $*" | tee -a "$LOG"; }

#Validasi jumlah parameter
if [ $# -ne 2 ]; then
    echo "Pemakaian: $0 <sumber> <tujuan>" >&2
    exit 1
fi

SUMBER="${1%/}"
TUJUAN="${2%/}"

#Validasi sumber -> exit 2
if [ ! -d "$SUMBER" ] || [ ! -r "$SUMBER" ]; then
    log "GAGAL: sumber tidak tersedia/tidak terbaca: $SUMBER"
    exit 2
fi

#Validasi tujuan -> exit 3
if [ ! -d "$TUJUAN" ] || [ ! -w "$TUJUAN" ]; then
    log "GAGAL: tujuan tidak dapat ditulis: $TUJUAN"
    exit 3
fi

#Buat arsip bertimestamp
NAMA="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
ARSIP="$TUJUAN/$NAMA"

if ! tar -czf "$ARSIP" -C "$(dirname "$SUMBER")" "$(basename "$SUMBER")"; then
    log "GAGAL: tar mengembalikan error"
    rm -f "$ARSIP"
    exit 1
fi

#Buat file .sha256 (cd dulu agar yang tercatat hanya nama file)
if ! ( cd "$TUJUAN" && sha256sum "$NAMA" > "$NAMA.sha256" ); then
    log "GAGAL: pembuatan checksum"
    rm -f "$ARSIP" "$ARSIP.sha256"
    exit 1
fi

log "OK: arsip=$ARSIP checksum=$ARSIP.sha256"
echo "$ARSIP"
exit 0
