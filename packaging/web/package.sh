#!/usr/bin/env bash
# Build FilmCraft Web (`cargo xtask web` + `pack_wasm.py` parallel gzip chunks) and stage it in $ROOT/dist/filmcraft-web-<version>/
set -euo pipefail
# shellcheck source=../env.sh
. "$(dirname "${BASH_SOURCE[0]}")/../env.sh"
HERE="$ROOT/packaging/web"

if [[ "${1:-}" != "--skip-build" ]]; then
  WASM_BINDGEN_VERSION="$(sed -n 's/^const WASM_BINDGEN: &str = "\(.*\)";$/\1/p' "$ROOT/xtask/src/main.rs")"
  if ! { command -v wasm-bindgen >/dev/null && wasm-bindgen --version | grep -qF "$WASM_BINDGEN_VERSION"; }; then
    mkdir -p "$HOME/.cargo/bin"
    curl -fsSL "https://github.com/rustwasm/wasm-bindgen/releases/download/${WASM_BINDGEN_VERSION}/wasm-bindgen-${WASM_BINDGEN_VERSION}-x86_64-unknown-linux-gnu.tar.gz" \
      | tar -xzf - --strip-components=1 -C "$HOME/.cargo/bin" \
      || cargo install wasm-bindgen-cli --version "$WASM_BINDGEN_VERSION" --locked
  fi
  (cd "$ROOT" && cargo xtask web)
  python3 "$ROOT/apps/filmcraft-web/pack_wasm.py" "$CARGO_TARGET_DIR/web/dist"
fi

SITE="$CARGO_TARGET_DIR/web/dist"
[[ -f "$SITE/index.html" ]] || { echo "error: $SITE/index.html missing; run without --skip-build" >&2; exit 1; }
if grep -Eq '(src|href)="/[^/]' "$SITE/index.html"; then
  echo "error: $SITE/index.html has root-absolute URLs; it would break when served from a sub-path" >&2
  exit 1
fi

NAME="filmcraft-web-$VERSION"
WORK="$CARGO_TARGET_DIR/web-package"
rm -rf "$WORK"
mkdir -p "$WORK/$NAME"
cp -R "$SITE/." "$WORK/$NAME/"
cp "$HERE/_headers" "$HERE/.htaccess" "$WORK/$NAME/"
cp "$HERE/README.md" "$WORK/$NAME/HOSTING.md"
copy_docs "$WORK/$NAME"

rm -rf "$ROOT/dist/$NAME" "$DIST/$NAME.zip"
mkdir -p "$ROOT/dist"
cp -R "$WORK/$NAME" "$ROOT/dist/$NAME"
echo "staged directory $ROOT/dist/$NAME"

if command -v zip >/dev/null 2>&1; then
  mkdir -p "$DIST"
  (cd "$WORK" && zip -qr9 "$DIST/$NAME.zip" "$NAME")
  echo "wrote $DIST/$NAME.zip"
  ls -lh "$DIST/$NAME.zip"
fi
