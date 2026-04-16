#!/usr/bin/env bash
# install-deps.sh
# Run this from the root of the project where you want to use figma-visual-compare.
# It installs all required Node.js and Python dependencies.

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

ok()   { echo -e "${GREEN}✔${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC}  $*"; }
fail() { echo -e "${RED}✘${NC} $*"; exit 1; }

echo ""
echo "figma-visual-compare — dependency installer"
echo "============================================"
echo ""

# ── Node.js ──────────────────────────────────────────────────────────────────

if ! command -v node &>/dev/null; then
  fail "Node.js not found. Install it from https://nodejs.org and rerun this script."
fi
ok "Node.js $(node --version)"

if ! command -v npm &>/dev/null; then
  fail "npm not found. It should come with Node.js."
fi

# Check / install @playwright/test
if node -e "require('@playwright/test')" &>/dev/null 2>&1; then
  ok "@playwright/test already installed"
else
  warn "@playwright/test not found — installing..."
  npm install --save-dev @playwright/test
  ok "@playwright/test installed"
fi

# Check / install sharp
if node -e "require('sharp')" &>/dev/null 2>&1; then
  ok "sharp already installed"
else
  warn "sharp not found — installing..."
  npm install --save-dev sharp
  ok "sharp installed"
fi

# Install Playwright browser binary
echo ""
echo "Installing Playwright Chromium browser binary..."
npx playwright install chromium
ok "Chromium installed"

# ── Python ────────────────────────────────────────────────────────────────────

echo ""

PYTHON=""
for cmd in python3 python; do
  if command -v "$cmd" &>/dev/null; then
    PYTHON="$cmd"
    break
  fi
done

if [ -z "$PYTHON" ]; then
  fail "Python 3 not found. Install it from https://python.org and rerun this script."
fi

PYTHON_VERSION=$("$PYTHON" --version 2>&1 | awk '{print $2}')
PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)

if [ "$PYTHON_MINOR" -lt 10 ]; then
  fail "Python 3.10+ required (found $PYTHON_VERSION). Please upgrade Python."
fi
ok "Python $PYTHON_VERSION"

# Check / install numpy
if "$PYTHON" -c "import numpy" &>/dev/null 2>&1; then
  ok "numpy already installed"
else
  warn "numpy not found — installing..."
  "$PYTHON" -m pip install numpy
  ok "numpy installed"
fi

# Check / install Pillow
if "$PYTHON" -c "from PIL import Image" &>/dev/null 2>&1; then
  ok "Pillow already installed"
else
  warn "Pillow not found — installing..."
  "$PYTHON" -m pip install Pillow
  ok "Pillow installed"
fi

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo "============================================"
ok "All dependencies are ready."
echo ""
echo "Next step: make sure your Figma API token is set."
echo "  Add to .env or export in your shell:"
echo ""
echo "  FIGMA_API_TOKEN=<your-token>"
echo ""
echo "Get a token at: https://www.figma.com/settings → Personal access tokens"
echo ""
