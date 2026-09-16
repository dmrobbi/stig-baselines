XCCDFS_RHEL7 := $(wildcard sources/rhel7/*/*xccdf.xml)
XCCDFS_RHEL8 := $(wildcard sources/rhel8/*/*xccdf.xml)
XCCDFS_RHEL9 := $(wildcard sources/rhel9/*/*xccdf.xml)
XCCDFS_ESXI  := $(wildcard sources/vsphere67/*ESXi*xccdf.xml)
XCCDFS_VC    := $(wildcard sources/vsphere67/*vCenter*xccdf.xml)

.PHONY: all baselines validate check-tool dist clean

all: baselines validate

# bash-invoked (not ./) so the script works even when an archive transfer
# (zip) drops the executable bit.
baselines:
	bash tools/build.sh

validate:
	@set -e; for f in baselines/*/*.ckl; do xmllint --noout --schema tools/schema/U_Checklist_Schema_V2.xsd $$f; done
	@echo "all CKLs schema-valid (DISA Checklist v2.5)"

check-tool:
	python3 -m py_compile tools/xccdf2ckl.py tools/merge_ckl.py tools/csv2ckl.py

# Clean, deterministic transfer archive for offline/USB use: committed
# tree only (no .git, no __pycache__), with a sha256 for integrity check
# on the destination system.
dist:
	@mkdir -p dist
	@git archive --format=tar.gz -o dist/stig-baselines.tar.gz HEAD
	@sha256sum dist/stig-baselines.tar.gz | tee dist/stig-baselines.tar.gz.sha256
	@echo "dist/stig-baselines.tar.gz ready (committed tree only)"

clean:
	rm -rf tools/__pycache__