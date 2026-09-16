#!/usr/bin/env python3
"""
csv2ckl - Apply assessment results from a CSV to a baseline CKL.

Lets you bulk-record an evaluation without hand-editing STIG Viewer:
statuses are enum-checked against DISA's Checklist schema v2.5, so the
output stays schema-valid and opens cleanly in STIG Viewer 2.x/3.x.

CSV columns (header row required):
  rule             Rule_Ver, Rule_ID, or Vuln_Num of the VULN to update
  status           Open | NotAFinding | Not_Applicable | Not_Reviewed
  finding_details  optional evidence text
  comments         optional comments

Usage:
  python3 csv2ckl.py IN.ckl results.csv OUT.ckl

Exit codes: 0 = ok, 1 = error (bad status value / unreadable inputs).
"""
import csv
import sys
import xml.etree.ElementTree as ET

VALID_STATUS = {"Open", "NotAFinding", "Not_Applicable", "Not_Reviewed"}


def main():
    if len(sys.argv) != 4:
        print("usage: csv2ckl.py IN.ckl results.csv OUT.ckl", file=sys.stderr)
        return 1
    ckl_path, csv_path, out_path = sys.argv[1:4]

    try:
        rows = list(csv.DictReader(open(csv_path, newline="")))
    except OSError as e:
        print(f"ERROR: cannot read {csv_path}: {e}", file=sys.stderr)
        return 1

    try:
        tree = ET.parse(ckl_path)
    except ET.ParseError as e:
        print(f"ERROR: {ckl_path} is not valid XML: {e}", file=sys.stderr)
        return 1
    vulns = tree.getroot().findall("./STIGS/iSTIG/VULN")
    if not vulns:
        print(f"ERROR: no VULN entries in {ckl_path}", file=sys.stderr)
        return 1

    by_key: dict = {}
    for v in vulns:
        fields = {d.findtext("VULN_ATTRIBUTE"): d.findtext("ATTRIBUTE_DATA")
                  for d in v.findall("STIG_DATA")}
        for key in (fields.get("Rule_Ver"), fields.get("Rule_ID"),
                    fields.get("Vuln_Num")):
            if key:
                by_key.setdefault(key, []).append(v)

    hit = 0
    for r in rows:
        key = (r.get("rule") or "").strip()
        status = (r.get("status") or "").strip()
        targets = by_key.get(key)
        if not targets:
            print(f"WARN: rule {key!r} not found in CKL — skipped",
                  file=sys.stderr)
            continue
        if status not in VALID_STATUS:
            print(f"ERROR: invalid status {status!r} for {key} "
                  f"(valid: {sorted(VALID_STATUS)})", file=sys.stderr)
            return 1
        for v in targets:
            v.find("STATUS").text = status
            v.find("FINDING_DETAILS").text = r.get("finding_details") or ""
            v.find("COMMENTS").text = r.get("comments") or ""
        hit += 1

    ET.indent(tree, space="  ")
    tree.write(out_path, encoding="UTF-8", xml_declaration=True)
    print(f"updated {hit}/{len(rows)} CSV rows "
          f"({len(by_key)} rules indexed, {len(vulns)} VULNs) -> {out_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())