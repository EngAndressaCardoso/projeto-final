## Backup e Restauração (Fase 6)
Para restaurar os dados do banco em caso de falha, primeiro pare a instância 'db' com 'lxc stop db' para evitar corrupção. Em seguida, restaure o snapshot do volume executando 'lxc storage volume restore pool-final vol-db snap-volume'. Por fim, inicie o contêiner novamente com 'lxc start db' e valide o acesso no navegador. Os backups exportados ('.tar.gz') ficam armazenados em '~/backup' com retenção de snapshots configurada para 7 dias.

## Fase 7 — Automacao e reprodutibilidade (deploy.sh)

Script idempotente (`set -euo pipefail`) para provisionar e configurar o ambiente LXD (`net-prod`, `pool-final`, `vol-db`, perfis e instancias `db`, `app` e `proxy`), incluindo MariaDB, WordPress (`https://servico.lab:8444`), certificados TLS (`conf/tls/`) e Nginx.

### Validacao e idempotencia
- Sintaxe: `chmod +x deploy.sh && bash -n deploy.sh`
- Execucao dupla: `./deploy.sh && ./deploy.sh`
- Teste HTTPS: `curl -Ik --resolve servico.lab:8444:127.0.0.1 https://servico.lab:8444`
