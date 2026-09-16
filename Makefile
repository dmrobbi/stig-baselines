XCCDFS_RHEL7 := $(wildcard sources/rhel7/*/*xccdf.xml)
XCCDFS_RHEL8 := $(wildcard sources/rhel8/*/*xccdf.xml)
XCCDFS_RHEL9 := $(wildcard sources/rhel9/*/*xccdf.xml)
XCCDFS_ESXI  := $(wildcard sources/vsphere67/*ESXi*xccdf.xml)
XCCDFS_VC    := $(wildcard sources/vsphere67/*vCenter*xccdf.xml)

.PHONY: all baselines validate check-tool clean

all: baselines validate

baselines:
	tools/build.sh

validate:
	@set -e; for f in baselines/*/*.ckl; do xmllint --noout --schema tools/schema/U_Checklist_Schema_V2.xsd $$f; done
	@echo "all CKLs schema-valid (DISA Checklist v2.5)"

check-tool:
	python3 -m py_compile tools/xccdf2ckl.py tools/merge_ckl.py tools/csv2ckl.py

clean:
	rm -rf tools/__pycache__