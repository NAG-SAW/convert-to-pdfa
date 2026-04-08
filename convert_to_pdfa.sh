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
 -dCompatibilityLevel=1.4 \
 -dPDFSETTINGS=/printer \
 -dPDFA=1 \
 -dPDFACompatibilityPolicy=1 \
 -sProcessColorModel=DeviceRGB \
 -sColorConversionStrategy=RGB \
 -sOutputICCProfile="$ICC_PATH" \
 -dNOPAUSE -dQUIET -dBATCH \
 -sOutputFile="../$2" \
 "../$1"

# TODO: This yields smaller files faster, but it prints
# GPL Ghostscript 10.05.1: 
#        pdfwrite cannot guarantee creating a conformant PDF/A-2 file with device-independent colour.
#        We recommend converting to a device colour space.
#        We cannot ignore this request, reverting to normal output.
#
# gs \
#  -sDEVICE=pdfwrite \
#  -dPDFA=2 \
#  -dPDFACompatibilityPolicy=1 \
#  -sColorConversionStrategy=UseDeviceIndependentColor \
#  -dNOPAUSE -dQUIET -dBATCH \
#  -sOutputFile="../$2" \
#  "../$1"
