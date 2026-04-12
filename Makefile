PROJECT   = freewrite.xcodeproj
SCHEME    = freewrite
BUILD_DIR = build/Release
APP       = freewrite.app

# Use xcpretty for cleaner output if available
XCPRETTY := $(shell command -v xcpretty 2>/dev/null)
PIPE      = $(if $(XCPRETTY),| xcpretty,)

.PHONY: all release release-unsigned open clean

all: release

# Signed release build (requires a valid Mac Developer certificate)
release:
	@mkdir -p $(BUILD_DIR)
	xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration Release \
		CONFIGURATION_BUILD_DIR=$(CURDIR)/$(BUILD_DIR) \
		build \
		$(PIPE)
	@echo ""
	@echo "Built: $(BUILD_DIR)/$(APP)"

# Unsigned build — for local testing without a developer certificate
release-unsigned:
	@mkdir -p $(BUILD_DIR)
	xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration Release \
		CONFIGURATION_BUILD_DIR=$(CURDIR)/$(BUILD_DIR) \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO \
		build \
		$(PIPE)
	@echo ""
	@echo "Built (unsigned): $(BUILD_DIR)/$(APP)"

open: release-unsigned
	open $(BUILD_DIR)/$(APP)

clean:
	rm -rf build
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration Release clean -quiet
