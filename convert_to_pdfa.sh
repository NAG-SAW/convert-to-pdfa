#!/bin/env bash
set -o pipefail

USAGE="convert_to_pdfa.sh <INPUT> <OUTPUT>"
if [[ ! -f "$1" ]]; then
    echo "File \"$1\" not found!"
    echo "$USAGE"
    exit 1
fi
if [[ -z "$2" ]]; then
    echo "$USAGE"
    exit 1
fi

# Find color profile if something changes
ICC_PATH="/usr/share/color/icc/sRGB.icc"
if [[ ! -f "$ICC_PATH" ]]; then
    ICC_PATH=$(find /usr/share/color/icc -name 'sRGB*.icc' | head -n 1)
    if [ -z "$ICC_PATH" ]; then echo "sRGB ICC profile not found" >&2; exit 1; fi
    echo "Using different ICC_PATH=$ICC_PATH"
fi

cd processed
gs --permit-file-read="$ICC_PATH" \
 -sDEVICE=pdfwrite \
 -dCompatibilityLevel=1.7 \
 -sProcessColorModel=DeviceRGB \
 -sColorConversionStrategy=RGB \
 -sOutputICCProfile="$ICC_PATH" \
 -dEmbedAllFonts=true \
 -dEmbedSubstituteFonts=true \
 -dSubsetFonts=true \
 -dCompressFonts=true \
 -dNOPAUSE -dBATCH -dQUIET -dSAFER \
 -sOutputFile="../$2" \
 "../$1"
