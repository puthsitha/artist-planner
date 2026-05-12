# ---------------------------------------------------------------------------
# Artist Planner — flavor x mode run shortcuts
#
# Six combinations:
#   make dev          / make dev-release
#   make stage        / make stage-release
#   make prod         / make prod-release
#
# Each target is `flutter run --flavor <name> --target lib/main_<name>.dart`
# in either debug (default) or release mode.
#
# Optional: pass DEVICE=<id> to target a specific device, e.g.
#   make dev DEVICE=00008110-0014245A0234801E
# ---------------------------------------------------------------------------

DEVICE ?=
DEVICE_ARG := $(if $(DEVICE),-d $(DEVICE),)

FLUTTER ?= flutter

.PHONY: help \
        dev stage prod \
        dev-release stage-release prod-release \
        build-dev-apk build-stage-apk build-prod-apk \
        build-dev-ipa build-stage-ipa build-prod-ipa \
        clean

help:
	@echo "Run targets:"
	@echo "  make dev              # development flavor, debug"
	@echo "  make stage            # staging flavor, debug"
	@echo "  make prod             # production flavor, debug"
	@echo "  make dev-release      # development flavor, release"
	@echo "  make stage-release    # staging flavor, release"
	@echo "  make prod-release     # production flavor, release"
	@echo ""
	@echo "Build targets:"
	@echo "  make build-{dev,stage,prod}-apk    # Android release APK"
	@echo "  make build-{dev,stage,prod}-ipa    # iOS release IPA"
	@echo ""
	@echo "Pass DEVICE=<id> to pin a device:"
	@echo "  make dev DEVICE=00008110-0014245A0234801E"

# ---- Debug (hot reload) ----------------------------------------------------

dev:
	$(FLUTTER) run $(DEVICE_ARG) --flavor development --target lib/main_development.dart

stage:
	$(FLUTTER) run $(DEVICE_ARG) --flavor staging --target lib/main_staging.dart

prod:
	$(FLUTTER) run $(DEVICE_ARG) --flavor production --target lib/main_production.dart

# ---- Release (AOT, optimized) ---------------------------------------------

dev-release:
	$(FLUTTER) run --release $(DEVICE_ARG) --flavor development --target lib/main_development.dart

stage-release:
	$(FLUTTER) run --release $(DEVICE_ARG) --flavor staging --target lib/main_staging.dart

prod-release:
	$(FLUTTER) run --release $(DEVICE_ARG) --flavor production --target lib/main_production.dart

# ---- Build artifacts -------------------------------------------------------

build-dev-apk:
	$(FLUTTER) build apk --release --flavor development --target lib/main_development.dart

build-stage-apk:
	$(FLUTTER) build apk --release --flavor staging --target lib/main_staging.dart

build-prod-apk:
	$(FLUTTER) build apk --release --flavor production --target lib/main_production.dart

build-dev-ipa:
	$(FLUTTER) build ipa --release --flavor development --target lib/main_development.dart

build-stage-ipa:
	$(FLUTTER) build ipa --release --flavor staging --target lib/main_staging.dart

build-prod-ipa:
	$(FLUTTER) build ipa --release --flavor production --target lib/main_production.dart

clean:
	$(FLUTTER) clean
