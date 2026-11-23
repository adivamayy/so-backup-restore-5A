#!/usr/bin/env bash
cd "$(dirname "$0")/.." || exit 1
S=scripts/validate_input.sh
T=$(mktemp -d)
mkdir "$T/ada_isi" "$T/kosong"
echo "dummy" > "$T/ada_isi/a.txt"

run() { echo "\$ $S $*"; "$S" "$@"; echo "exit: $?"; echo; }

echo "== (+) sumber valid, harapan exit 0";        run "$T/ada_isi"
echo "== (-) sumber tidak ada, harapan exit 2";    run "$T/tidak_ada"
echo "== (-) sumber kosong, harapan exit 2";       run "$T/kosong"
echo "== (-) tanpa parameter, harapan exit 2";     run
rm -rf "$T"
