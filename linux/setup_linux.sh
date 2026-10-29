#!/usr/bin/env bash
# ==============================================================================
# Dirac Opteo & 3D Spatial Audio Setup for Linux (PipeWire + EasyEffects)
# ==============================================================================

set -e

echo "=== Installing Dirac Opteo Preset for EasyEffects ==="

PRESET_DIR="$HOME/.config/easyeffects/output"
CONV_DIR="$HOME/.config/easyeffects/irs"

mkdir -p "$PRESET_DIR"
mkdir -p "$CONV_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Copy EasyEffects preset
cp "$REPO_DIR/config/dirac_opteo_easyeffects.json" "$PRESET_DIR/"
echo "Installed EasyEffects preset to: $PRESET_DIR/dirac_opteo_easyeffects.json"

# Copy Convolution IR
cp "$REPO_DIR/config/dirac_spatial.wav" "$CONV_DIR/"
echo "Installed 3D Spatial IR to: $CONV_DIR/dirac_spatial.wav"

echo ""
echo "=== Setup Complete ==="
echo "1. Open EasyEffects."
echo "2. Go to Presets -> Output -> select 'dirac_opteo_easyeffects' -> Load."
echo "3. In Convolver plugin, select 'dirac_spatial.wav' for 3D spatialization."
