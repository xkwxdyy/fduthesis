#!/usr/bin/env sh

# Create local CTAN, TDS and Overleaf archives from trusted release sources.
set -eu
umask 077

JOB_NAME=fduthesis
WORKING_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
STAGING_DIR=$(mktemp -d "${TMPDIR:-/tmp}/fduthesis-release.XXXXXX")
trap 'rm -rf -- "$STAGING_DIR"' EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

# The private parent protects every intermediate tree from pre-seeded files.
TEMP_DIR="$STAGING_DIR/work"
TDS_DIR="$STAGING_DIR/TDS"
CTAN_ROOT="$STAGING_DIR/CTAN"
CTAN_DIR="$CTAN_ROOT/$JOB_NAME"
OVERLEAF_DIR="$STAGING_DIR/overleaf"
SRC_DIR="$TDS_DIR/source/latex/$JOB_NAME"
TEX_DIR="$TDS_DIR/tex/latex/$JOB_NAME"
DOC_DIR="$TDS_DIR/doc/latex/$JOB_NAME"
LOGO_DIR="$WORKING_DIR/logo/pdf"
RELEASE_DIR="$WORKING_DIR/release"
DOC_EN_SCRIPT="$WORKING_DIR/scripts/get-doc-en.lua"

mkdir -p "$TEMP_DIR" "$CTAN_DIR" "$OVERLEAF_DIR" "$SRC_DIR" "$TEX_DIR" "$DOC_DIR"

cp "$WORKING_DIR"/source/*.dtx            "$TEMP_DIR/"
cp "$WORKING_DIR"/source/*.pdf            "$TEMP_DIR/"
cp "$WORKING_DIR/docs/main.tex"           "$TEMP_DIR/"
cp "$WORKING_DIR/docs/main.bib"           "$TEMP_DIR/"
cp "$WORKING_DIR"/docs/*.png              "$TEMP_DIR/"
cp "$LOGO_DIR/fudan-emblem-a-black.pdf"     "$TEMP_DIR/fudan-emblem.pdf"
cp "$LOGO_DIR/fudan-emblem-new-a-black.pdf" "$TEMP_DIR/fudan-emblem-new.pdf"
cp "$LOGO_DIR/fudan-name-black.pdf"         "$TEMP_DIR/fudan-name.pdf"

cd "$TEMP_DIR"
xetex "$JOB_NAME.dtx" > /dev/null
texlua "$DOC_EN_SCRIPT" "$JOB_NAME.dtx" "$JOB_NAME-en.tex"
chmod 644 "$TEMP_DIR"/*.*

cp "$TEMP_DIR"/*.dtx "$SRC_DIR/"
cp "$TEMP_DIR"/*.ins "$SRC_DIR/"
cp "$TEMP_DIR"/*.cls "$TEX_DIR/"
cp "$TEMP_DIR"/*.def "$TEX_DIR/"
cp "$TEMP_DIR"/*.sty "$TEX_DIR/"
cp "$TEMP_DIR/fudan-emblem.pdf" "$TEMP_DIR/fudan-emblem-new.pdf" "$TEMP_DIR/fudan-name.pdf" "$TEX_DIR/"
cp "$TEMP_DIR"/*.md "$DOC_DIR/"
cp "$TEMP_DIR"/*.tex "$DOC_DIR/"
cp "$TEMP_DIR"/"$JOB_NAME"*.pdf "$DOC_DIR/"
rm "$DOC_DIR/main.tex"

cp "$TEMP_DIR/$JOB_NAME.cls" "$TEMP_DIR/$JOB_NAME-en.cls" "$TEMP_DIR/$JOB_NAME.def" "$OVERLEAF_DIR/"
cp "$TEMP_DIR/main.tex" "$TEMP_DIR/main.bib" "$TEMP_DIR"/*.png "$OVERLEAF_DIR/"
cp "$TEMP_DIR/fudan-emblem.pdf" "$TEMP_DIR/fudan-emblem-new.pdf" "$TEMP_DIR/fudan-name.pdf" "$OVERLEAF_DIR/"

cp "$TEMP_DIR"/*.dtx "$CTAN_DIR/"
cp "$TEMP_DIR"/*.md "$CTAN_DIR/"
cp "$TEMP_DIR"/*.pdf "$CTAN_DIR/"

# Archive entries should have normal readable modes; STAGING_DIR stays 0700.
find "$TDS_DIR" "$CTAN_ROOT" "$OVERLEAF_DIR" -type d -exec chmod 755 {} +
(
  cd "$TDS_DIR"
  zip -qr9 "$STAGING_DIR/$JOB_NAME.tds.zip" .
)
cp "$STAGING_DIR/$JOB_NAME.tds.zip" "$CTAN_ROOT/"
chmod 644 "$CTAN_ROOT/$JOB_NAME.tds.zip"
(
  cd "$CTAN_ROOT"
  zip -qr9 "$STAGING_DIR/$JOB_NAME.zip" .
)
(
  cd "$OVERLEAF_DIR"
  zip -qr9 "$STAGING_DIR/$JOB_NAME-overleaf.zip" .
)

# Do not touch existing releases until every archive has been built successfully.
chmod 644 "$STAGING_DIR"/*.zip
mkdir -p "$RELEASE_DIR"
cp "$STAGING_DIR/$JOB_NAME.tds.zip" "$STAGING_DIR/$JOB_NAME.zip" \
  "$STAGING_DIR/$JOB_NAME-overleaf.zip" "$RELEASE_DIR/"
