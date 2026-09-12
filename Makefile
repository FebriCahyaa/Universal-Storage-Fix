VERSION := $(shell sed -n 's/^version=//p' module/module.prop)
DIST := dist
MODULE_ZIP := $(DIST)/Universal-Storage-Fix-$(VERSION).zip
.PHONY: all native test package checksums verify clean
all: native package checksums
native:
	cmake -S native -B build/native -DCMAKE_BUILD_TYPE=Release
	cmake --build build/native --parallel
test: native
	./build/native/usf_native_tests
	sh tests/test-shell.sh
	node tools/validate-update.mjs update.json
package:
	mkdir -p $(DIST)
	find module -type f ! -name '*.zip' -print | LC_ALL=C sort | zip -X -q $(MODULE_ZIP) -@
	@echo "Built $(MODULE_ZIP)"
checksums: package
	tools/security/generate-checksums.sh $(DIST)
verify: checksums
	tools/security/verify-checksums.sh $(DIST)/SHA256SUMS
	tools/security/verify-release.sh $(DIST) update.json
clean:
	rm -rf build $(DIST)
