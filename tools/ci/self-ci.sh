#!/usr/bin/env bash
# Self-CI for the central workflows repo: every reusable workflow must be
# valid YAML, every third-party `uses:` must be SHA-pinned, every shell
# snippet must parse. Examples may reference this repo via <CENTRAL_SHA>
# placeholders (resolved at consumer switch time).
set -euo pipefail

cd "$(cd -P "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

status=0

echo '==> yaml-parse'
while IFS= read -r f; do
  python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" "$f" \
    || { echo "FAIL invalid yaml: $f"; status=1; }
done < <(find .github/workflows examples -name '*.yml' -type f)
echo "   $(find .github/workflows examples -name '*.yml' | wc -l) files"

echo '==> sha-pinning'
violations=$(grep -rhoE 'uses:[[:space:]]*[^[:space:]]+@[^\s]+' .github/workflows examples 2>/dev/null \
  | sed -E 's/uses:[[:space:]]*//; s/[[:space:]]*#.*$//' \
  | grep -v '@<CENTRAL_SHA>$' \
  | grep -vE '@[0-9a-f]{40}$' || true)
if [[ -n "$violations" ]]; then
  echo "FAIL unpinned action refs (must be full 40-hex SHA):"
  echo "$violations"
  status=1
else
  echo '   all action refs SHA-pinned'
fi

echo '==> shell-syntax'
while IFS= read -r sh; do
  bash -n "$sh" || { echo "FAIL bash syntax: $sh"; status=1; }
done < <(find . -name '*.sh' -type f -not -path './.git/*')

[[ $status -eq 0 ]] && echo '✓ self-ci passed' || echo '✗ self-ci failed'
exit "$status"
