#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REQ_FILE="${1:-$ROOT_DIR/spec/management/requirements-checklist.md}"

if [ ! -f "$REQ_FILE" ]; then
  echo "requirements file not found: $REQ_FILE" >&2
  exit 1
fi

awk -F'|' '
function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
function group_from_source(src,    a, n) {
  src = trim(src)
  if (src ~ /^Annex /) {
    n = split(src, a, " ")
    if (n >= 2) {
      split(a[2], b, ".")
      return "Annex " b[1]
    }
    return "Annex"
  }
  if (src ~ /^[0-9]/) return "Main Clauses"
  return "Other"
}
$0 ~ /^\| R-[0-9][0-9][0-9][0-9] / {
  req = trim($2)
  src = trim($3)
  pri = trim($5)
  st = trim($7)
  grp = group_from_source(src)

  total++
  status_total[st]++

  group_total[grp]++
  group_status[grp SUBSEP st]++

  if (pri == "Must") {
    must_total++
    must_status[st]++
    must_group_total[grp]++
    must_group_status[grp SUBSEP st]++
  }
}
END {
  printf("requirements coverage report\n")
  printf("source: %s\n\n", FILENAME)

  printf("[overall]\n")
  printf("  total=%d\n", total)
  printf("  Planned=%d InProgress=%d Implemented=%d Verified=%d N-A=%d\n\n",
    status_total["Planned"], status_total["InProgress"], status_total["Implemented"], status_total["Verified"], status_total["N-A"])

  printf("[must]\n")
  printf("  total=%d\n", must_total)
  printf("  Planned=%d InProgress=%d Implemented=%d Verified=%d N-A=%d\n\n",
    must_status["Planned"], must_status["InProgress"], must_status["Implemented"], must_status["Verified"], must_status["N-A"])

  printf("[must by group]\n")
  split("Main Clauses,Annex A,Annex B,Annex C,Annex D,Annex E,Annex F,Annex G,Annex H,Annex I,Annex M,Other", ordered, ",")
  for (oi in ordered) {
    g = ordered[oi]
    if (!(g in must_group_total)) continue
    t = must_group_total[g]
    v = must_group_status[g SUBSEP "Verified"]
    i = must_group_status[g SUBSEP "Implemented"]
    p = must_group_status[g SUBSEP "Planned"]
    ip = must_group_status[g SUBSEP "InProgress"]
    na = must_group_status[g SUBSEP "N-A"]
    cov = (t > 0 ? (100.0 * v / t) : 0)
    printf("  %s: total=%d verified=%d implemented=%d inprogress=%d planned=%d na=%d verified_coverage=%.1f%%\n", g, t, v, i, ip, p, na, cov)
  }
}
' "$REQ_FILE"
