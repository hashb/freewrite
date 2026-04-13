SHELL   := /bin/bash

PROJECT          = freewrite.xcodeproj
SCHEME           = freewrite
BUILD            = build
VERSION          ?= 1.6
NOTARIZE         ?= true
KEYCHAIN_PROFILE ?= notarytool

ARCHIVE = $(BUILD)/Freewrite.xcarchive
EXPORT  = $(BUILD)/export
DMG     = $(BUILD)/Freewrite-$(VERSION).dmg

TEAM_ID := $(shell security find-identity -v -p codesigning 2>/dev/null \
	| grep -m1 "Developer ID Application" \
	| sed 's/.*(\(.*\)).*/\1/' \
	| tr -d ' ')

.PHONY: all release release-unsigned open dmg bump-version clean

all: release

# Quick signed build for local use
release:
	mkdir -p $(BUILD)/Release
	xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration Release \
		CONFIGURATION_BUILD_DIR=$(CURDIR)/$(BUILD)/Release \
		build

# Unsigned build for local testing without a developer certificate
release-unsigned:
	mkdir -p $(BUILD)/Release
	xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration Release \
		CONFIGURATION_BUILD_DIR=$(CURDIR)/$(BUILD)/Release \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO \
		build

open: release-unsigned
	open $(BUILD)/Release/$(SCHEME).app

# Archive → export → DMG → (optional) notarize + staple
# Usage:
#   make dmg                             # signed DMG
#   make dmg NOTARIZE=true               # + notarize + staple
#   make dmg NOTARIZE=true VERSION=1.2
#
# One-time notarization setup:
#   xcrun notarytool store-credentials "notarytool"
dmg:
	@[ -n "$(TEAM_ID)" ] || { echo "No Developer ID Application certificate found in Keychain"; exit 1; }
	@echo "Team ID: $(TEAM_ID)"
	rm -rf $(BUILD) && mkdir -p $(BUILD)
	xcodebuild archive \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration Release \
		-archivePath $(ARCHIVE) \
		DEVELOPMENT_TEAM=$(TEAM_ID) \
		CODE_SIGN_STYLE=Manual \
		CODE_SIGN_IDENTITY="Developer ID Application"
	printf '%s\n' \
		'<?xml version="1.0" encoding="UTF-8"?>' \
		'<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' \
		'<plist version="1.0"><dict>' \
		'<key>method</key><string>developer-id</string>' \
		'<key>signingStyle</key><string>manual</string>' \
		"<key>teamID</key><string>$(TEAM_ID)</string>" \
		'</dict></plist>' > $(BUILD)/ExportOptions.plist
	xcodebuild -exportArchive \
		-archivePath $(ARCHIVE) \
		-exportOptionsPlist $(BUILD)/ExportOptions.plist \
		-exportPath $(EXPORT)
	npx create-dmg $(EXPORT)/$(SCHEME).app $(BUILD)/ 2>&1 || true
	mv "$$(find $(BUILD) -maxdepth 1 -name '*.dmg' | head -1)" $(DMG)
	@echo "DMG: $(DMG)"
	@if [ "$(NOTARIZE)" = "true" ]; then \
		echo "Notarizing..."; \
		xcrun notarytool submit "$(DMG)" --keychain-profile "$(KEYCHAIN_PROFILE)" --wait; \
		echo "Stapling..."; \
		xcrun stapler staple "$(DMG)"; \
		xcrun stapler validate "$(DMG)"; \
		echo "Done: $(DMG)"; \
	else \
		echo "Done. Run 'make dmg NOTARIZE=true' to notarize."; \
	fi

# Bump MARKETING_VERSION in Xcode project
# Usage: make bump-version VERSION=1.7
bump-version:
	@[ -n "$(VERSION)" ] || { echo "Usage: make bump-version VERSION=x.y"; exit 1; }
	sed -i '' 's/MARKETING_VERSION = [^;]*/MARKETING_VERSION = $(VERSION)/' $(PROJECT)/project.pbxproj
	@echo "Version bumped to $(VERSION)"

clean:
	rm -rf build
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration Release clean -quiet
