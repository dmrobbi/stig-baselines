#!/usr/bin/env python3
"""stig-baselines bulk adder: fetch current DISA STIG XCCDFs from cyber.trackr.live
and generate baseline CKLs via tools/xccdf2ckl.py.

Families: VMware vSphere 6.5/7.0/8.0 (+vCenter appliance sub-STIGs), vRA 7.x,
vROps 6.x, NSX-T/NSX 4.x, Horizon 7.13, Workspace ONE, Citrix, Microsoft email
(Exchange 2013/2016/2019, Outlook 2013/2016). Plus vSphere 6.7 sub-component
CKLs generated from the repo's committed bundle sources.

Outputs:
  sources/<fam>/...            XCCDFs (new, committed)
  baselines/<fam>/...ckl       baseline CKLs
  /tmp/stig-manifest.json      full manifest for verification
  /tmp/build-snippet.sh        lines to splice into tools/build.sh
  /tmp/readme-rows.md          rows for the README baseline table
  /tmp/src-readme-rows.md      rows for sources/README provenance table
"""
import hashlib
import json
import re
import subprocess
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path
from xml.etree import ElementTree as ET

BASE = "https://cyber.trackr.live"
REPO = Path(__file__).resolve().parent.parent
CATALOG = Path("/tmp/trackr-stigs.json")
MANIFEST = Path("/tmp/stig-manifest.json")
BUILD_SNIPPET = Path("/tmp/build-snippet.sh")
README_ROWS = Path("/tmp/readme-rows.md")
SRC_README_ROWS = Path("/tmp/src-readme-rows.md")
UA = {"User-Agent": "stig-baselines-fetch/1.0 (repo tooling)"}

# title -> (family, role)   role=None keeps converter default (matches existing
# vSphere 6.7 baselines, which carry ROLE=None).
TRACKR_TARGETS = [
    # --- vSphere 6.5 ---
    ("VMware_vSphere_6.5_ESXi", "vsphere65", None),
    ("VMW_vSphere_6.5_vCenter_Server_for_Windows", "vsphere65", None),
    ("VMware_vSphere_6.5_Virtual_Machine", "vsphere65", None),
    # --- vSphere 7.0 + vCenter appliance sub-STIGs ---
    ("VMware_vSphere_7.0_ESXi", "vsphere70", None),
    ("VMware_vSphere_7.0_VAMI", "vsphere70", None),
    ("VMware_vSphere_7.0_Virtual_Machine", "vsphere70", None),
    ("VMware_vSphere_7.0_vCenter", "vsphere70", None),
    ("VMware_vSphere_7.0_vCenter_Appliance_EAM", "vsphere70", None),
    ("VMware_vSphere_7.0_vCenter_Appliance_Lookup_Service", "vsphere70", None),
    ("VMware_vSphere_7.0_vCenter_Appliance_Perfcharts", "vsphere70", None),
    ("VMware_vSphere_7.0_vCenter_Appliance_Photon_OS", "vsphere70", None),
    ("VMware_vSphere_7.0_vCenter_Appliance_PostgreSQL", "vsphere70", None),
    ("VMware_vSphere_7.0_vCenter_Appliance_RhttpProxy", "vsphere70", None),
    ("VMware_vSphere_7.0_vCenter_Appliance_STS", "vsphere70", None),
    ("VMware_vSphere_7.0_vCenter_Appliance_UI", "vsphere70", None),
    # --- vSphere 8.0 + vCenter appliance sub-STIGs ---
    ("VMware_vSphere_8.0_ESXi", "vsphere80", None),
    ("VMware_vSphere_8.0_Virtual_Machine", "vsphere80", None),
    ("VMware_vSphere_8.0_vCenter", "vsphere80", None),
    ("VMware_vSphere_8.0_vCenter_Appliance_ESX_Agent_Manager_(EAM)", "vsphere80", None),
    ("VMware_vSphere_8.0_vCenter_Appliance_Envoy", "vsphere80", None),
    ("VMware_vSphere_8.0_vCenter_Appliance_Lookup_Service", "vsphere80", None),
    ("VMware_vSphere_8.0_vCenter_Appliance_Management_Interface_(VAMI)", "vsphere80", None),
    ("VMware_vSphere_8.0_vCenter_Appliance_Perfcharts", "vsphere80", None),
    ("VMware_vSphere_8.0_vCenter_Appliance_Photon_OS_4.0", "vsphere80", None),
    ("VMware_vSphere_8.0_vCenter_Appliance_PostgreSQL", "vsphere80", None),
    ("VMware_vSphere_8.0_vCenter_Appliance_Secure_Token_Service_(STS)", "vsphere80", None),
    ("VMware_vSphere_8.0_vCenter_Appliance_User_Interface_(UI)", "vsphere80", None),
    # --- vRealize Automation 7.x ---
    ("VMware_Automation_7.x_Application", "vra7", None),
    ("VMW_vRealize_Automation_7.x_HA_Proxy", "vra7", None),
    ("VMware_vRealize_Automation_7.x_Lighttpd", "vra7", None),
    ("VMW_vRealize_Automation_7.x_PostgreSQL", "vra7", None),
    ("VMware_vRealize_Automation_7.x_SLES", "vra7", None),
    ("VMware_vRealize_Automation_7.x_tc_Server", "vra7", None),
    ("VMware_vRealize_Automation_7.x_vAMI", "vra7", None),
    ("VMware_vRealize_Automation_7.x_vIDM", "vra7", None),
    # --- vRealize Operations Manager 6.x ---
    ("VMware_vRealize_Operations_Manager_6.x_Application", "vrops6", None),
    ("VMW_vRealize_Operations_Manager_6.x_PostgreSQL", "vrops6", None),
    ("VMware_vRealize_Operations_Manager_6.x_SLES", "vrops6", None),
    ("VMware_vRealize_Operations_Manager_6.x_tc_Server", "vrops6", None),
    ("VMware_vRealize_Ops_Mgr_-_Cassandra", "vrops6", None),
    # --- NSX (T + 4.x) ---
    ("VMware_NSX-T_SDN_Controller", "nsx", None),
    ("VMware_NSX-T_Manager_NDM", "nsx", None),
    ("VMware_NSX-T_Distributed_Firewall", "nsx", None),
    ("VMware_NSX-T_Tier-0_Gateway_Firewall", "nsx", None),
    ("VMware_NSX-T_Tier-0_Gateway_RTR", "nsx", None),
    ("VMware_NSX-T_Tier_1_Gateway_Firewall", "nsx", None),
    ("VMware_NSX-T_Tier_1_Gateway_RTR", "nsx", None),
    ("VMware_NSX_4.x_Distributed_Firewall", "nsx", None),
    ("VMware_NSX_4.x_Manager_NDM", "nsx", None),
    ("VMware_NSX_4.x_Tier-0_Gateway_Firewall", "nsx", None),
    ("VMware_NSX_4.x_Tier-0_Gateway_Router", "nsx", None),
    ("VMware_NSX_4.x_Tier-1_Gateway_Firewall", "nsx", None),
    ("VMware_NSX_4.x_Tier-1_Gateway_Router", "nsx", None),
    # --- Horizon / Workspace ONE ---
    ("VMware_Horizon_7.13_Agent", "horizon", None),
    ("VMware_Horizon_7.13_Client", "horizon", None),
    ("VMware_Horizon_7.13_Connection_Server", "horizon", None),
    ("VMware_Workspace_ONE_UEM", "workspace_one", None),
    # --- Citrix (all current library entries) ---
    ("Citrix_Virtual_Apps_and_Desktop_7.x_Delivery_Controller", "citrix", "Member Server"),
    ("Citrix_Virtual_Apps_and_Desktop_7.x_License_Server", "citrix", "Member Server"),
    ("Citrix_Virtual_Apps_and_Desktop_7.x_Linux_Virtual_Delivery_Agent", "citrix", None),
    ("Citrix_Virtual_Apps_and_Desktop_7.x_StoreFront", "citrix", "Member Server"),
    ("Citrix_Virtual_Apps_and_Desktop_7.x_Windows_Virtual_Delivery_Agent", "citrix", "Member Server"),
    ("Citrix_Virtual_Apps_and_Desktop_7.x_Workspace_App", "citrix", "Workstation"),
    ("Citrix_XenDesktop_7.x_Delivery_Controller", "citrix", "Member Server"),
    ("Citrix_XenDesktop_7.x_License_Server", "citrix", "Member Server"),
    ("Citrix_XenDesktop_7.x_Receiver", "citrix", "Workstation"),
    ("Citrix_XenDesktop_7.x_StoreFront", "citrix", "Member Server"),
    ("Citrix_XenDesktop_7.x_Windows_VDA", "citrix", "Member Server"),
    ("Citrix_XenDesktop_7.x_Windows_Virtual_Delivery_Agent", "citrix", "Member Server"),
    ("Citrix_XenDesktop_v7.x_StoreFront", "citrix", "Member Server"),
    # --- Microsoft email: Exchange ---
    ("Exchange_2013_Client_Access_Server", "exchange", "Member Server"),
    ("Exchange_2013_Edge_Transport_Server", "exchange", "Member Server"),
    ("Exchange_2013_Mailbox_Server", "exchange", "Member Server"),
    ("Exchange_2016_Edge_Transport_Server", "exchange", "Member Server"),
    ("Exchange_2016_Mailbox_Server", "exchange", "Member Server"),
    ("Exchange_2019_Edge_Server", "exchange", "Member Server"),
    ("Exchange_2019_Mailbox_Server", "exchange", "Member Server"),
    # --- Microsoft email: Outlook ---
    ("Outlook_2013", "outlook", "Workstation"),
    ("Outlook_2016", "outlook", "Workstation"),
]

LABEL_OVERRIDES = {
    "VMware_Automation_7.x_Application": "VMware vRealize Automation 7.x Application",
    "VMW_vRealize_Ops_Mgr_-_Cassandra": "VMware vRealize Operations Manager 6.x Cassandra",
    "VMW_vSphere_6.5_vCenter_Server_for_Windows": "VMware vSphere 6.5 vCenter Server for Windows",
}


def human_label(title: str) -> str:
    if title in LABEL_OVERRIDES:
        return LABEL_OVERRIDES[title]
    if title.startswith("VMW_"):
        title = "VMware_" + title[4:]
    if title.startswith("Exchange_"):
        return "Microsoft Exchange " + title[len("Exchange_"):].replace("_", " ")
    if title.startswith("Outlook_"):
        return "Microsoft Outlook " + title[len("Outlook_"):].replace("_R", " R")
    return title.replace("_", " ")


def get(url: str, timeout: int = 90) -> bytes:
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return r.read()


def http_code(url: str, timeout: int = 60) -> int:
    try:
        req = urllib.request.Request(url, headers=UA)
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.status
    except urllib.error.HTTPError as e:
        return e.code


def load_catalog() -> dict:
    if CATALOG.exists() and CATALOG.stat().st_size > 100_000:
        return json.loads(CATALOG.read_text())
    data = get(BASE + "/api/stig", timeout=120)
    CATALOG.write_bytes(data)
    return json.loads(data)


def releases_desc(cat: dict, title: str):
    rels = cat.get(title) or []
    seen, out = set(), []
    for e in sorted(rels, key=lambda x: (x.get("date") or "1990", int(x.get("version") or 0),
                                         int(x.get("release") or 0)), reverse=True):
        key = (int(e["version"]), int(e["release"]))
        if key in seen:
            continue
        seen.add(key)
        out.append((e.get("date") or "?", e["version"], e["release"], e.get("sev") or {}))
    return out


def fetch_xccdf(title: str, version: str, release: str):
    """Returns (bytes, filename from content-disposition)."""
    url = f"{BASE}/stig/{urllib.parse.quote(title, safe='._()-')}/{version}/{release}/download"
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=120) as r:
        cd = r.headers.get("Content-Disposition", "")
        data = r.read()
        if r.status != 200 or not data:
            raise RuntimeError(f"HTTP {r.status}, {len(data)} bytes")
        if not data.lstrip().startswith(b"<?xml") and b"<" not in data[:200]:
            raise RuntimeError("response is not XML")
        m = re.search(r'filename=(?P<f>[^;\r\n]+)', cd)
        fname = m.group("f").strip().strip('"') if m else f"U_{title}_V{version}R{release}_Manual-xccdf.xml"
        return data, fname


FNAME_RE = re.compile(r'^U_(?P<id>.+?)_STIG_V(?P<v>\d+)R(?P<r>\d+)_(?P<kind>\w+?)-xccdf\.xml$')


def parse_fname(fname: str):
    m = FNAME_RE.match(fname)
    if not m:
        # tolerate things like U_X_STIG_V2R3_Manual-xccdf.xml with odd ids
        return None
    return m.groupdict()


def xml_meta(data: bytes):
    """(rules, benchmark_id, title, status_date)"""
    try:
        root = ET.fromstring(data)
    except ET.ParseError:
        # some files may contain a leading stylesheet PI only; fromstring handles PIs, so
        # a failure is a real parse error
        raise
    rules = 0
    for el in root.iter():
        ln = el.tag.rsplit("}", 1)[-1]
        if ln == "Rule":
            rules += 1
    bid = root.get("id") or ""
    title_text = ""
    for el in root.iter():
        if el.tag.rsplit("}", 1)[-1] == "title" and el.text:
            title_text = el.text.strip()
            break
    sdate = ""
    for el in root.iter():
        if el.tag.rsplit("}", 1)[-1] == "status":
            sdate = el.get("date") or ""
            break
    return rules, bid, title_text, sdate


def convert(src: Path, out: Path, role) -> str:
    out.parent.mkdir(parents=True, exist_ok=True)
    cmd = ["python3", "tools/xccdf2ckl.py", str(src), str(out)]
    if role:
        cmd += ["--role", role]
    p = subprocess.run(cmd, cwd=REPO, capture_output=True, text=True, timeout=120)
    if p.returncode != 0:
        raise RuntimeError(f"{src.name}: {p.stdout.strip()} {p.stderr.strip()}")
    return out.read_text().count("<VULN>")


def main():
    cat = load_catalog()
    rows = []
    failures = []

    # --- local vSphere 6.7 sub-component sources (bundle already committed) ---
    for d in sorted((REPO / "sources/vsphere67").iterdir()):
        if not d.is_dir():
            continue
        xl = sorted(d.glob("*Manual-xccdf.xml"))
        if not xl:
            xl = sorted(d.glob("*xccdf.xml"))
        if not xl:
            continue
        xccdf = xl[0]
        base = xccdf.name
        if base.endswith("-xccdf.xml"):
            base = base[: -len("-xccdf.xml")]
        m = re.match(r"U_(?P<id>.+?)_STIG_V(?P<v>\d+)R(?P<r>\d+)_Manual$", base)
        if not m:
            print(f"SKIP (no name match): {xccdf}")
            continue
        out_rel = f"baselines/vsphere67/{base}-baseline.ckl"
        out = REPO / out_rel
        if out.exists():
            continue  # ESXi 6.7 / vCenter 6.7 already in repo
        comp = xccdf.parent.name
        try:
            rules_n, _bid, _t, sdate = xml_meta(xccdf.read_bytes())
        except Exception as e:
            print(f"SKIP (xml parse {e}): {xccdf}")
            continue
        _id = m.group("id")
        nice = _id.replace("VMW_", "VMware_").replace("_", " ").replace(" 6-7 ", " 6.7 ")
        rows.append(dict(mode="local", title=comp, family="vsphere67", release_v=int(m["v"]),
                         release_r=int(m["r"]), release_date=sdate or None,label=nice, role=None,
                         dir=d.name, xccdf=str(xccdf.relative_to(REPO)), ckl=out_rel,
                         orig_filename=xccdf.name, rules=rules_n, ckl_vulns=None, sha=None, date=sdate or None))

    # --- trackr downloads ---
    idx = 0
    for title, family, role in TRACKR_TARGETS:
        idx += 1
        rels = releases_desc(cat, title)
        if not rels:
            failures.append((title, "no catalog releases"))
            continue
        got = None
        errs = []
        for (date, ver, rel, sev) in rels:
            try:
                data, fname = fetch_xccdf(title, ver, rel)
                got = (date, ver, rel, sev, data, fname)
                break
            except Exception as e:
                errs.append(f"V{ver}R{rel}: {e}")
                time.sleep(2)
        if not got:
            failures.append((title, "; ".join(errs)))
            continue
        date, ver, rel, sev, data, fname = got
        info = parse_fname(fname)
        if info:
            sub = f"U_{info['id']}_V{int(info['v'])}R{int(info['r'])}_{info['kind']}_STIG"
        else:
            sub = title
        sdir = REPO / "sources" / family / sub
        sdir.mkdir(parents=True, exist_ok=True)
        spath = sdir / fname
        spath.write_bytes(data)
        sha = hashlib.sha256(data).hexdigest()[:12]
        try:
            rules, bid, btitle, bdate = xml_meta(data)
        except ET.ParseError as e:
            failures.append((title, f"XML parse: {e}"))
            continue
        label = human_label(title)
        base = fname[:-len("-xccdf.xml")] if fname.endswith("-xccdf.xml") else fname
        ckl_rel = f"baselines/{family}/{base}-baseline.ckl"
        rows.append(dict(mode="trackr", title=title, family=family, release_v=int(ver),
                         release_r=int(rel), release_date=date, label=label, role=role,
                         dir=sdir.name, xccdf=str(spath.relative_to(REPO)), ckl=ckl_rel,
                         orig_filename=fname,
                         benchmark_id=bid, benchmark_title=btitle, status_date=bdate,
                         rules=rules, sev=sev, sha=sha, fname_errors=None))
        print(f"[{idx}/{len(TRACKR_TARGETS)}] {title} V{ver}R{rel} rules={rules} sha={sha} {fname}", flush=True)
        time.sleep(1.0)

    # --- convert everything ---
    for i, row in enumerate(rows):
        if row.get("mode") == "trackr" and (row.get("rules") or 0) == 0:
            failures.append((row["title"], "0 rules in XCCDF — skipping"))
            row["ckl_vulns"] = None
            continue
        try:
            role = row["role"]
            cklv = convert(REPO / row["xccdf"], REPO / row["ckl"], role)
            row["ckl_vulns"] = cklv
            row["sha"] = row.get("sha") or "local"
        except Exception as e:
            failures.append((row.get("title") or row.get("xccdf"), f"convert: {e}"))
            continue
    MANIFEST.write_text(json.dumps(rows, indent=1))

    # --- snippets ---
    bl, rr, sr = [], [], []
    groups = {}
    for row in rows:
        if row.get("ckl_vulns") is None:
            continue
        groups.setdefault(row["family"], []).append(row)
    fam_order = ["vsphere65", "vsphere67", "vsphere70", "vsphere80", "vra7", "vrops6",
                 "nsx", "horizon", "workspace_one", "citrix", "exchange", "outlook"]
    fam_header = {
        "vsphere65": "VMware vSphere 6.5", "vsphere67": "VMware vSphere 6.7 sub-components",
        "vsphere70": "VMware vSphere 7.0", "vsphere80": "VMware vSphere 8.0",
        "vra7": "VMware vRealize Automation 7.x", "vrops6": "VMware vRealize Operations 6.x",
        "nsx": "VMware NSX", "horizon": "VMware Horizon 7.13",
        "workspace_one": "VMware Workspace ONE", "citrix": "Citrix",
        "exchange": "Microsoft Exchange", "outlook": "Microsoft Outlook",
    }
    for fam in fam_order:
        rs = sorted(groups.get(fam, []), key=lambda r: r["label"])
        if not rs:
            continue
        bl.append(f"echo '== {fam_header[fam]} =='")
        for r in rs:
            role = f" --role '{r['role']}'" if r.get("role") else ""
            bl.append(f"python3 tools/xccdf2ckl.py {r['xccdf'].replace('sources/', 'sources/')} baselines/../{r['ckl']}{role}")
            bl[-1] = f"python3 tools/xccdf2ckl.py {r['xccdf']} {r['ckl']}{role}"
            rr.append(f"| {r['label']} | V{r['release_v']}R{r['release_r']} | {r.get('release_date') or r.get('date') or '?'} | {r['ckl_vulns']} | `{r['ckl']}` |")
            src = f"`{r['xccdf']}`"
            if r.get("mode") == "trackr":
                prov = f"cyber.trackr.live `{BASE}/stig/{r['title']}/{r['release_v']}/{r['release_r']}/download`"
            else:
                prov = "vSphere 6.7 bundle `U_VMW_vSphere_6-7_Y23M07_STIG.zip` (already in repo)"
            sr.append(f"| {r['label']} | {src} | V{r['release_v']}R{r['release_r']}, {r.get('release_date') or r.get('date') or '?'} | {prov} |")
    BUILD_SNIPPET.write_text("\n".join(bl) + "\n")
    README_ROWS.write_text("\n".join(rr) + "\n")
    SRC_README_ROWS.write_text("\n".join(sr) + "\n")

    ok = [r for r in rows if r.get("ckl_vulns") is not None]
    total = sum(r["ckl_vulns"] or 0 for r in ok)
    print(f"\nOK: {len(ok)}/{len(rows)} converts, {total} total rules")
    if failures:
        print("FAILURES:")
        for t, e in failures:
            print(f"  {t}: {e[:300]}")
    print(f"manifest: {MANIFEST}")


if __name__ == "__main__":
    main()