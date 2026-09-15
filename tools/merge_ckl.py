#!/usr/bin/env python3
"""
merge_ckl - Merge multiple DISA STIG Viewer CKLs into one multi-STIG checklist.

The merged file contains one <iSTIG> block per input (STIG Viewer 2.x/3.x shows
each STIG separately in the checklist). The ASSET block comes from the first
input.

Usage: python3 merge_ckl.py IN1.ckl IN2.ckl [...] OUT.ckl
"""
import argparse
import sys
import xml.etree.ElementTree as ET


def ln(el):
    return str(getattr(el, "tag", el)).rsplit("}", 1)[-1]


def main():
    p = argparse.ArgumentParser(description="Merge CKLs into a multi-STIG checklist")
    p.add_argument("inputs", nargs="+", help="input CKLs (first provides ASSET block)")
    p.add_argument("out", help="output merged CKL")
    args = p.parse_args()

    roots = [ET.parse(f).getroot() for f in args.inputs]
    for f, r in zip(args.inputs, roots):
        if ln(r) != "CHECKLIST":
            print(f"ERROR: {f} is not a CHECKLIST file", file=sys.stderr)
            return 1

    merged = ET.Element("CHECKLIST")
    asset = roots[0].find("ASSET")
    if asset is not None:
        merged.append(asset)  # moves element from first tree; originals unused
    else:
        ET.SubElement(merged, "ASSET")

    stigs = ET.SubElement(merged, "STIGS")
    total = 0
    for r in roots:
        istigs = r.findall("./STIGS/iSTIG")
        if not istigs:
            print("ERROR: no iSTIG block found", file=sys.stderr)
            return 1
        for istig in istigs:
            stigs.append(istig)
            total += len(istig.findall("VULN"))

    tree = ET.ElementTree(merged)
    ET.indent(tree, space="  ")
    tree.write(args.out, encoding="UTF-8", xml_declaration=True)
    print(f"merged {len(roots)} CKLs -> {args.out} ({total} VULNs total)")
    return 0


if __name__ == "__main__":
    sys.exit(main())