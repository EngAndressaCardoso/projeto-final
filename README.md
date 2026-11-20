## Backup e Restauração (Fase 6)
Para restaurar os dados do banco em caso de falha, primeiro pare a instância 'db' com 'lxc stop db' para evitar corrupção. Em seguida, restaure o snapshot do volume executando 'lxc storage volume restore pool-final vol-db snap-volume'. Por fim, inicie o contêiner novamente com 'lxc start db' e valide o acesso no navegador. Os backups exportados ('.tar.gz') ficam armazenados em '~/backup' com retenção de snapshots configurada para 7 dias.

## Fase 7 — Automacao e reprodutibilidade (deploy.sh)

Script idempotente (`set -euo pipefail`) para provisionar e configurar o ambiente LXD (`net-prod`, `pool-final`, `vol-db`, perfis e instancias `db`, `app` e `proxy`), incluindo MariaDB, WordPress (`https://servico.lab:8444`), certificados TLS (`conf/tls/`) e Nginx.

### Validacao e idempotencia
- Sintaxe: `chmod +x deploy.sh && bash -n deploy.sh`
- Execucao dupla: `./deploy.sh && ./deploy.sh`
- Teste HTTPS: `curl -Ik --resolve servico.lab:8444:127.0.0.1 https://servico.lab:8444`

### Rodar em uma VM nova e ambientes (PROD / DEV)
1. Clone o repositório e acesse `~/projeto-final`.
2. Verifique se o LXD está instalado e inicializado na VM nova, com os arquivos de configuração e certificados em `conf/` (`conf/tls/`, `conf/nginx-servico.conf`, `conf/config-mariadb.sh`, `conf/instala-wp.sh`).
3. Para provisionar produção (`ENV=prod`, padrão, porta `8444`):
   `ENV=prod ./deploy.sh`
4. Para provisionar desenvolvimento (`ENV=dev`, porta `8082`):
   `ENV=dev ./deploy.sh`
5. Para conferir as instâncias em execução:
   `lxc list`
6. Para remover instâncias (e volumes com `--volumes`):
   `ENV=prod ./scripts/destroy.sh --volumes`
   `ENV=dev ./scripts/destroy.sh --volumes`
