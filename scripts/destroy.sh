#!/usr/bin/env bash
set -euo pipefail

ENV="${ENV:-prod}"
POOL="pool-final"
[ "$ENV" = "prod" ] && PREFIXO="" || PREFIXO="dev-"

for i in proxy app db; do
  lxc delete -f "${PREFIXO}${i}" 2>/dev/null || true
done

echo "Instâncias removidas. Os volumes foram mantidos (use --volumes para apagá-los)."

if [ "${1:-}" = "--volumes" ]; then
  for v in $(lxc storage volume list "$POOL" -c n --format csv | grep "^${PREFIXO}vol-"); do
    lxc storage volume delete "$POOL" "${v%%/*}" 2>/dev/null || true
  done
  echo "Volumes do pool '$POOL' com prefixo '${PREFIXO}' removidos."
fi
