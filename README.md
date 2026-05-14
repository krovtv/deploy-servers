# 🚀 Deploy Servers - Provisionamento Automatizado (Debian)

Scripts em shell para provisionamento automatizado de servidores Debian, com foco em padronização, automação e consistência de ambiente.

O projeto permite subir rapidamente ambientes para:

* 🌐 Servidor Web (Apache + PHP)
* 🗄️ Servidor de Banco (MariaDB)
* 🧩 Ambiente completo (Web + Banco)

---

## 📁 Estrutura do Projeto

```bash
.
├── lib.sh      # Funções reutilizáveis
├── base.sh     # Configuração base do sistema
├── web.sh      # Provisionamento web
├── db.sh       # Provisionamento banco
└── full.sh     # Provisionamento completo
```

---

## ⚙️ Requisitos

* Debian (versão recente recomendada)
* Acesso root ou sudo
* Conexão com internet

---

## ▶️ Como usar

```bash
git clone https://github.com/SEU-USUARIO/deploy-servers.git
cd deploy-servers
chmod +x *.sh
```

---

## 🌐 Servidor Web

```bash
sudo ./web.sh
```

Provisiona:

* Apache2
* PHP-FPM e extensões
* Configuração básica do ambiente web

---

## 🗄️ Servidor de Banco

```bash
sudo ./db.sh
```

Provisiona:

* MariaDB
* Criação de banco e usuário
* Geração automática de senha
* Controle de acesso por IP
* Configuração de acesso remoto (opcional)

---

## 🧩 Servidor Completo

```bash
sudo ./full.sh
```

Executa:

* Base + Web + Banco

---

## 🔐 Segurança (Resumo)

* Firewall ativo (UFW)
* Fail2Ban para proteção básica
* Restrição de acesso ao banco por IP
* Serviços expostos apenas quando necessário

---

## 🧠 Arquitetura

O projeto segue separação por responsabilidade:

* **base.sh** → configuração comum
* **web.sh** → serviços web
* **db.sh** → serviços de banco

Benefícios:

* Reutilização
* Independência entre scripts
* Execução previsível

---

## 🔁 Idempotência

Os scripts podem ser executados múltiplas vezes sem:

* Reinstalar pacotes
* Duplicar configurações
* Quebrar serviços existentes

---

## ⚠️ Observações

* O acesso ao banco pode ser restrito ou aberto conforme escolha durante execução
* Algumas configurações dependem da ordem correta de serviços (ex: MariaDB antes do Fail2Ban)
* Caso ocorra erro no Fail2Ban, verifique se o diretório `/etc/fail2ban/jail.d/` existe:

```bash
mkdir -p /etc/fail2ban/jail.d
```

---

## 🧹 Pós-provisionamento

Os scripts são utilizados apenas durante o processo de provisionamento.

Após a execução, o diretório do projeto pode ser removido do servidor:

```bash
rm -rf deploy-servers
```

Recomenda-se manter o projeto versionado (ex: GitHub) para reutilização futura ou novos ambientes.

---

## 🏷️ Versionamento

Formato:

```bash
MAJOR.MINOR.PATCH
```

* **MAJOR** → mudanças incompatíveis
* **MINOR** → novas funcionalidades
* **PATCH** → correções

---

## 👨‍💻 Autor

Kauã — Infraestrutura / SysAdmin

---

## 📄 Licença

Uso livre para fins educacionais e profissionais.
