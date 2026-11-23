#!/bin/bash
S=/tmp/sumber_uji
T=/tmp/tujuan_uji
mkdir -p "$S" "$T"
echo "data uji" > "$S/a.txt"

jalankan() {
    echo "\$ ./scripts/archive.sh $1 $2"
    ./scripts/archive.sh "$1" "$2"
    echo "exit: $?"
    echo
}

jalankan "$S" "$T"                 # positif, harapan 0
jalankan /tmp/tidak_ada "$T"       # negatif sumber, harapan 2
jalankan "$S" /tmp/tidak_ada       # negatif tujuan, harapan 3
