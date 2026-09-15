XCCDFS_RHEL7 := $(wildcard sources/rhel7/*/*xccdf.xml)
XCCDFS_RHEL8 := $(wildcard sources/rhel8/*/*xccdf.xml)
XCCDFS_RHEL9 := $(wildcard sources/rhel9/*/*xccdf.xml)
XCCDFS_ESXI  := $(wildcard sources/vsphere67/*ESXi*xccdf.xml)
XCCDFS_VC    := $(wildcard sources/vsphere67/*vCenter*xccdf.xml)

.PHONY: all convert validate check-tool clean

all: convert validate

convert:
	python3 tools/xccdf2ckl.py $(XCCDFS_RHEL7) baselines/rhel7/$(notdir $(subst -xccdf.xml,-baseline.ckl,$(XCCDFS_RHEL7)))
	python3 tools/xccdf2ckl.py $(XCCDFS_RHEL8) baselines/rhel8/$(notdir $(subst -xccdf.xml,-baseline.ckl,$(XCCDFS_RHEL8)))
	python3 tools/xccdf2ckl.py $(XCCDFS_RHEL9) baselines/rhel9/$(notdir $(subst -xccdf.xml,-baseline.ckl,$(XCCDFS_RHEL9)))
	python3 tools/xccdf2ckl.py $(XCCDFS_ESXI) baselines/vsphere67/$(notdir $(subst -xccdf.xml,-baseline.ckl,$(XCCDFS_ESXI)))
	python3 tools/xccdf2ckl.py $(XCCDFS_VC) baselines/vsphere67/$(notdir $(subst -xccdf.xml,-baseline.ckl,$(XCCDFS_VC)))

validate:
	@set -e; for f in baselines/*/*.ckl; do xmllint --noout $$f; done
	@echo "all CKLs well-formed"

check-tool:
	python3 -m py_compile tools/xccdf2ckl.py

clean:
	rm -f tools/__pycache__/*