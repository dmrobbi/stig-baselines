#!/usr/bin/env python3
"""
xccdf2ckl - Convert a DISA STIG XCCDF Benchmark into a STIG Viewer baseline CKL.

Reads an XCCDF 1.1/1.2 Benchmark (DISA "Manual" STIGs) and emits a CKL checklist
compatible with DISA STIG Viewer 2.x/3.x. Every Group/Rule becomes a VULN entry
with all canonical STIG_DATA fields populated; statuses default to Not_Reviewed
(baseline) or to results from an optional XCCDF results file.

Usage:
  python3 xccdf2ckl.py <input-xccdf.xml> <output.ckl>
      [--status Not_Reviewed|NotAFinding|Open|Not_Applicable]
      [--results <oscap-results.xml>]      # optional: map pass/fail to statuses
      [--hostname H] [--ip IP] [--mac M] [--fqdn F] [--tech-area T]
      [--role R] [--asset-type T]

Exit codes: 0 = ok, 1 = error.
"""

import argparse
import os
import re
import sys
import uuid
import xml.etree.ElementTree as ET

# Canonical CKL field order (matches DISA STIG Viewer output)
STIG_DATA_ORDER = [
    "Vuln_Num", "Severity", "Group_Title", "Rule_ID", "Rule_Ver", "Rule_Title",
    "Vuln_Discuss", "Check_Content", "Check_Content_Ref", "Fix_Text",
    "False_Negatives", "False_Positives", "Documentable", "Mitigations",
    "Potential_Impact", "Third_Party_Tools", "Mitigation_Control",
    "Responsibility", "IA_Controls", "Security_Override_Guidance",
    "Weight", "Class", "CCI_REF",
]

SI_DATA_ORDER = [
    # 2026-09-16: names must be members of the SID_NAME enumeration in
    # DISA's Checklist schema v2.5 (U_Checklist_Schema_V2.xsd): 'class',
    # 'planguage' and 'purpose' are NOT in the set (schema validation
    # failed in STIG Viewer 2.18); 'stigid' replaces the missing STIG id.
    "version", "classification", "stigid", "title", "description",
    "filename", "releaseinfo", "source", "uuid",
]

ASSET_FIELDS = [
    # Order + required members per the Checklist schema: MARKING,
    # HOST_GUID and TARGET_COMMENT are optional (omitted); ASSET_GUID is
    # not in the schema at all (removed); WEB_OR_DATABASE must be a
    # boolean literal and WEB_DB_SITE/WEB_DB_INSTANCE are required.
    "ROLE", "ASSET_TYPE", "HOST_NAME", "HOST_IP", "HOST_MAC", "HOST_FQDN",
    "TECH_AREA", "TARGET_KEY", "STIG_GUID",
    "WEB_OR_DATABASE", "WEB_DB_SITE", "WEB_DB_INSTANCE",
]

ROLE_ENUM = {"None", "Workstation", "Member Server", "Domain Controller"}
ASSET_TYPE_ENUM = {"Computing", "Non-Computing"}

# XCCDF <description> escaped-HTML block -> CKL field
DESC_BLOCKS = {
    "FalseNegatives": "False_Negatives",
    "FalsePositives": "False_Positives",
    "Documentable": "Documentable",
    "Mitigations": "Mitigations",
    "PotentialImpacts": "Potential_Impact",
    "ThirdPartyTools": "Third_Party_Tools",
    "MitigationControl": "Mitigation_Control",
    "SeverityOverrideGuidance": "Security_Override_Guidance",
    "Responsibility": "Responsibility",
}

VALID_STATUS = {"Open", "NotAFinding", "Not_Applicable", "Not_Reviewed"}

# XCCDF rule-result -> CKL STATUS
RESULT_TO_STATUS = {
    "pass": "NotAFinding",
    "fail": "Open",
    "notapplicable": "Not_Applicable",
    "notchecked": "Not_Reviewed",
    "notselected": "Not_Reviewed",
    "informational": "Not_Reviewed",
    "error": "Not_Reviewed",
    "unknown": "Not_Reviewed",
    "fixed": "NotAFinding",
}


def ln(el):
    """Local name of an Element or tag string, namespace agnostic (XCCDF 1.1/1.2)."""
    tag = getattr(el, "tag", el)
    return str(tag).rsplit("}", 1)[-1]


def kids(el, name):
    return [c for c in el if ln(c.tag) == name]


def first(el, name):
    k = kids(el, name)
    return k[0] if k else None


def text_of(el):
    return "".join(el.itertext()).strip() if el is not None else ""


def parse_html_desc(raw):
    """XCCDF <description> holds escaped HTML blocks; return {block: [inner, ...]}."""
    out = {}
    if not raw:
        return out
    try:
        root = ET.fromstring("<root>" + raw.strip() + "</root>")
    except ET.ParseError:
        return out
    for child in root:
        name = ln(child)
        inner = child.text or ""
        for sub in list(child):
            inner += ET.tostring(sub, encoding="unicode")
        out.setdefault(name, []).append(inner.strip())
    return out


def plain_text_by_id(root):
    d = {}
    for pt in root.iter():
        if ln(pt.tag) == "plain-text" and pt.get("id"):
            d[pt.get("id")] = text_of(pt)
    return d


def walk_groups(el):
    for g in kids(el, "Group"):
        yield g
        yield from walk_groups(g)


def rule_to_vuln(rule, group):
    rid = rule.get("id", "")
    severity = rule.get("severity", "") or "low"
    if severity not in ("high", "medium", "low"):
        severity = "low"
    desc_el = first(rule, "description")
    blocks = parse_html_desc(text_of(desc_el))

    vd = (blocks.get("VulnDiscussion") or [""])[0]
    if not vd:
        vd = text_of(desc_el)

    check_el = None
    for c in kids(rule, "check"):
        if text_of(first(c, "check-content")):
            check_el = c
            break
    check_content = text_of(first(check_el, "check-content")) if check_el is not None else ""
    check_ref = (check_el.get("system") or "") if check_el is not None else ""

    fix_el = None
    for f in kids(rule, "fixtext"):
        if text_of(f):
            fix_el = f
            break
    fix_text = text_of(fix_el) if fix_el is not None else ""

    ccis = []
    for ident in kids(rule, "ident"):
        if "cci" in (ident.get("system") or "").lower():
            v = text_of(ident)
            if v and v not in ccis:
                ccis.append(v)

    def block1(name):
        vals = blocks.get(name) or [""]
        return vals[0]

    responsibilities = ", ".join(v for v in blocks.get("Responsibility", []) if v)

    return {
        "Vuln_Num": group.get("id", ""),
        "Severity": severity,
        "Group_Title": text_of(first(group, "title")),
        "Rule_ID": rid,
        "Rule_Ver": text_of(first(rule, "version")),
        "Rule_Title": text_of(first(rule, "title")),
        "Vuln_Discuss": vd,
        "Check_Content": check_content,
        "Check_Content_Ref": check_ref,
        "Fix_Text": fix_text,
        "False_Negatives": block1("FalseNegatives"),
        "False_Positives": block1("FalsePositives"),
        "Documentable": block1("Documentable"),
        "Mitigations": block1("Mitigations"),
        "Potential_Impact": block1("PotentialImpacts"),
        "Third_Party_Tools": block1("ThirdPartyTools"),
        "Mitigation_Control": block1("MitigationControl"),
        "Responsibility": responsibilities,
        "IA_Controls": "",
        "Security_Override_Guidance": block1("SeverityOverrideGuidance"),
        "Weight": rule.get("weight", ""),
        "Class": "Unclassified",
        "CCI_REF": " ".join(ccis),
    }


def build_stig_info(root, xccdf_path):
    ptmap = plain_text_by_id(root)
    bench_id = root.get("id", "")
    version = text_of(first(root, "version"))
    title = text_of(first(root, "title"))
    desc = text_of(first(root, "description"))
    uid = str(uuid.uuid5(uuid.NAMESPACE_URL, f"https://stig-baselines/{bench_id}/{version}"))
    return {
        "version": version,
        "classification": "Unclassified",
        "stigid": os.path.basename(xccdf_path).replace("-xccdf.xml", ""),
        "title": title,
        "description": desc,
        "filename": os.path.basename(xccdf_path),
        "uuid": uid,
        "releaseinfo": ptmap.get("release-info", ""),
        "source": "DISA - DoD Cyber Exchange (STIG content is public domain)",
    }


def load_results_map(results_path):
    """Return {rule_id: status} from an oscap XCCDF results file."""
    rroot = ET.parse(results_path).getroot()
    out = {}
    for rr in rroot.iter():
        if ln(rr.tag) != "rule-result":
            continue
        rid = rr.get("idref", "")
        res = text_of(first(rr, "result")).lower()
        if rid and res:
            out[rid] = RESULT_TO_STATUS.get(res, "Not_Reviewed")
    return out


def write_ckl(out_path, asset, si_data, vulns):
    if asset.get("ROLE", "None") not in ROLE_ENUM:
        print(f"ERROR: ROLE {asset.get('ROLE')!r} not in schema enum "
              f"{sorted(ROLE_ENUM)}", file=sys.stderr)
        return 1
    if asset.get("ASSET_TYPE", "Computing") not in ASSET_TYPE_ENUM:
        print(f"ERROR: ASSET_TYPE {asset.get('ASSET_TYPE')!r} not in "
              f"schema enum {sorted(ASSET_TYPE_ENUM)}", file=sys.stderr)
        return 1
    root = ET.Element("CHECKLIST")

    asset_el = ET.SubElement(root, "ASSET")
    for f in ASSET_FIELDS:
        ET.SubElement(asset_el, f).text = asset.get(f, "")

    stigs = ET.SubElement(root, "STIGS")
    istig = ET.SubElement(stigs, "iSTIG")
    si = ET.SubElement(istig, "STIG_INFO")
    for name in SI_DATA_ORDER:
        sd = ET.SubElement(si, "SI_DATA")
        ET.SubElement(sd, "SID_NAME").text = name
        data = si_data.get(name, "")
        if data:  # SID_DATA is optional — omit when empty
            ET.SubElement(sd, "SID_DATA").text = data

    stig_ref = f"{si_data.get('title', '')} :: v{si_data.get('version', '')}"
    m = re.search(r"Release:\s*(\d+)", si_data.get("releaseinfo") or "")
    if m:
        stig_ref += f"r{m.group(1)}"

    for v in vulns:
        vuln = ET.SubElement(istig, "VULN")
        sd = ET.SubElement(vuln, "STIG_DATA")
        ET.SubElement(sd, "VULN_ATTRIBUTE").text = "STIGRef"
        ET.SubElement(sd, "ATTRIBUTE_DATA").text = stig_ref
        for name in STIG_DATA_ORDER:
            sd = ET.SubElement(vuln, "STIG_DATA")
            ET.SubElement(sd, "VULN_ATTRIBUTE").text = name
            ET.SubElement(sd, "ATTRIBUTE_DATA").text = v.get(name, "")
        ET.SubElement(vuln, "STATUS").text = v["STATUS"]
        for extra in ("FINDING_DETAILS", "COMMENTS", "SEVERITY_OVERRIDE",
                      "SEVERITY_JUSTIFICATION"):
            ET.SubElement(vuln, extra).text = ""

    tree = ET.ElementTree(root)
    ET.indent(tree, space="  ")
    tree.write(out_path, encoding="UTF-8", xml_declaration=True)


def convert(xccdf_path, out_path, args):
    root = ET.parse(xccdf_path).getroot()
    if ln(root) != "Benchmark":
        print(f"ERROR: {xccdf_path}: root element is not Benchmark", file=sys.stderr)
        return 1

    si_data = build_stig_info(root, xccdf_path)
    results_map = load_results_map(args.results) if args.results else {}

    vulns = []
    skipped = 0
    for group in walk_groups(root):
        for rule in kids(group, "Rule"):
            v = rule_to_vuln(rule, group)
            if args.results and v["Rule_ID"] in results_map:
                v["STATUS"] = results_map[v["Rule_ID"]]
            else:
                v["STATUS"] = args.status
            if args.status not in VALID_STATUS:
                print(f"ERROR: invalid status {args.status}", file=sys.stderr)
                return 1
            vulns.append(v)
    if not vulns:
        print(f"ERROR: {xccdf_path}: no Group/Rule entries found", file=sys.stderr)
        return 1

    asset = {
        "ROLE": args.role,
        "ASSET_TYPE": args.asset_type,
        "HOST_NAME": args.hostname,
        "HOST_IP": args.ip,
        "HOST_MAC": args.mac,
        "HOST_FQDN": args.fqdn,
        "TARGET_KEY": "",
        "TECH_AREA": args.tech_area,
        "STIG_GUID": "",
        "WEB_OR_DATABASE": "false",
        "WEB_DB_SITE": "",
        "WEB_DB_INSTANCE": "",
    }

    write_ckl(out_path, asset, si_data, vulns)
    statuses = {}
    for v in vulns:
        statuses[v["STATUS"]] = statuses.get(v["STATUS"], 0) + 1
    stat_str = ", ".join(f"{k}={n}" for k, n in sorted(statuses.items()))
    print(f"OK  {out_path}")
    print(f"    {si_data['title']} (version {si_data['version']}, release: {si_data['releaseinfo']})")
    print(f"    vulns={len(vulns)} ({stat_str})")
    return 0


def main():
    p = argparse.ArgumentParser(description="DISA XCCDF -> STIG Viewer CKL baseline")
    p.add_argument("xccdf", help="input XCCDF benchmark file")
    p.add_argument("out", help="output CKL file")
    p.add_argument("--status", default="Not_Reviewed", help="default status (default Not_Reviewed)")
    p.add_argument("--results", help="optional oscap results.xml to derive statuses")
    p.add_argument("--hostname", default="", help="ASSET HOST_NAME")
    p.add_argument("--ip", default="", help="ASSET HOST_IP")
    p.add_argument("--mac", default="", help="ASSET HOST_MAC")
    p.add_argument("--fqdn", default="", help="ASSET HOST_FQDN")
    p.add_argument("--tech-area", default="", help="ASSET TECH_AREA")
    p.add_argument("--role", default="None", help="ASSET ROLE (None|Workstation|Member Server|Domain Controller)")
    p.add_argument("--asset-type", default="Computing", help="ASSET_TYPE (Computing|Non-Computing)")
    args = p.parse_args()
    sys.exit(convert(args.xccdf, args.out, args))


if __name__ == "__main__":
    main()