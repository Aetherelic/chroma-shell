#!/usr/bin/env bash

set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$root"

required_files=(
    shell.qml
    preview.sh
    SettingsStore.qml
    backend/chroma-settingsctl
    bin/chroma
    tools/chroma-doctor
    VERSION
    LICENSE
    packaging/layout.json
    packaging/capabilities.json
)

for file in "${required_files[@]}"; do
    test -f "$file" || {
        printf 'Missing required file: %s\n' "$file" >&2
        exit 1
    }
done

while IFS= read -r -d '' script; do
    bash -n "$script"
done < <(
    find . -type f \
        \( -name '*.sh' -o -path './bin/*' -o -path './backend/*ctl' -o -path './tools/chroma-doctor' \) \
        -print0
)

jq -e . packaging/layout.json >/dev/null
jq -e . packaging/capabilities.json >/dev/null

git diff --check

runtime_path_files=(
    SettingsStore.qml
    shell.qml
    preview.sh
    backend/chroma-settingsctl
    backend/chroma-clipboardctl
)

if grep -nE '(\$HOME|\$home)/Projects/chroma-shell|/home/[^/]+/Projects/chroma-shell' \
    "${runtime_path_files[@]}" \
    >/tmp/chroma-hardcoded-paths.$$ 2>/dev/null
then
    cat /tmp/chroma-hardcoded-paths.$$ >&2
    rm -f /tmp/chroma-hardcoded-paths.$$
    printf 'Hard-coded development paths remain.\n' >&2
    exit 1
fi
rm -f /tmp/chroma-hardcoded-paths.$$

python3 - <<'PY'
from pathlib import Path

pairs = {'{': '}', '[': ']', '(': ')'}
qml_files = list(Path('.').rglob('*.qml'))

for path in qml_files:
    text = path.read_text(encoding='utf-8')
    stack = []
    quote = None
    escaped = False
    line_comment = False
    block_comment = False
    i = 0

    while i < len(text):
        char = text[i]
        nxt = text[i + 1] if i + 1 < len(text) else ''

        if line_comment:
            if char == '\n':
                line_comment = False
            i += 1
            continue

        if block_comment:
            if char == '*' and nxt == '/':
                block_comment = False
                i += 2
            else:
                i += 1
            continue

        if quote:
            if escaped:
                escaped = False
            elif char == '\\':
                escaped = True
            elif char == quote:
                quote = None
            i += 1
            continue

        if char == '/' and nxt == '/':
            line_comment = True
            i += 2
            continue
        if char == '/' and nxt == '*':
            block_comment = True
            i += 2
            continue
        if char in ('"', "'"):
            quote = char
            i += 1
            continue
        if char in pairs:
            stack.append((char, i))
        elif char in pairs.values():
            if not stack or pairs[stack[-1][0]] != char:
                raise SystemExit(f'{path}: mismatched delimiter at byte {i}')
            stack.pop()
        i += 1

    if quote or block_comment or stack:
        raise SystemExit(f'{path}: unterminated string/comment/delimiter')

print(f'QML structure OK: {len(qml_files)} files')
PY

grep -Fq 'target: "chroma"' shell.qml
grep -Eq '^bind[[:space:]]*=[[:space:]]*SUPER SHIFT,[[:space:]]*V,' integration/hypr/chroma-desktop-tools.conf

./bin/chroma --version >/dev/null
./bin/chroma --help >/dev/null
./bin/chroma paths >/dev/null

printf 'CHROMA validation passed.\n'
