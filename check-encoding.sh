#!/usr/bin/env bash
#
# Every example must start with a UTF-8 BOM.
#
#   ./check-encoding.sh
#
# Windows PowerShell 5.1 reads a BOM-less file as ANSI, so the Persian text in
# these examples arrives mangled and the script may not even parse. PowerShell 7
# assumes UTF-8 and does not care, which is exactly what makes this easy to
# break without noticing: it keeps working for whoever edits it and fails for
# the Windows administrator the examples are written for.
#
# Git does not normalise a BOM away, so nothing in .gitattributes can enforce
# this. A check is the only guard.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
status=0

for file in "$ROOT"/examples/v3/*.ps1; do
	if [ "$(head -c 3 "$file" | od -An -tx1 | tr -d ' ')" = "efbbbf" ]; then
		echo "ok       $(basename "$file")"
	else
		echo "NO BOM   $(basename "$file")"
		status=1
	fi
done

if [ "$status" -ne 0 ]; then
	echo
	echo "Add one with:  printf '\xEF\xBB\xBF' | cat - file.ps1 > tmp && mv tmp file.ps1"
fi

exit $status
