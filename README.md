# 🚀 Deploy Servers - Provisionamento Automatizado (Debian)

Scripts em shell para provisionamento automatizado de servidores Debian, com foco em padronização, segurança e reexecução segura.

O projeto permite subir rapidamente ambientes organizados e reutilizáveis para:

* 🌐 Servidor Web (Apache + PHP)
* 🗄️ Servidor de Banco (MariaDB)
* 🧩 Ambiente completo (Web + Banco)

---

## 📁 Estrutura do Projeto

```bash
.
├── lib.sh      # Funções reutilizáveis (instalação, serviços, validações)
├── base.sh     # Configuração base do sistema (segurança e utilitários)
├── web.sh      # Provisionamento de servidor web
├── db.sh       # Provisionamento de banco de dados
└── full.sh     # Provisionamento completo (web + banco)
```

---

## ⚙️ Requisitos

* Debian (recomendado: versão recente)
* Acesso root ou sudo
* Conexão com internet

---

## ▶️ Como usar

Clone o repositório:

```bash
git clone https://github.com/SEU-USUARIO/deploy-servers.git
cd deploy-servers
```

Dê permissão de execução:

```bash
chmod +x *.sh
```

---

## 🌐 Servidor Web

```bash
sudo ./web.sh
```

Configura automaticamente:

* Apache2
* PHP-FPM + extensões
* Módulos essenciais do Apache
* Fail2Ban (proteção HTTP)

---

## 🗄️ Servidor de Banco

```bash
sudo ./db.sh
```

Fluxo:

* Criação do banco de dados
* Criação de usuário isolado
* Geração automática de senha
* Controle de acesso por IP
* Sincronização de permissões
* Configuração de log do MariaDB
* Integração com Fail2Ban

---

## 🧩 Servidor Completo

```bash
sudo ./full.sh
```

Executa:

* Base + Web + Banco automaticamente

---

## 🔐 Segurança

O projeto implementa:

* UFW ativo por padrão
* Fail2Ban modular (`jail.d`)
* Proteção SSH (base)
* Proteção HTTP (web)
* Proteção MySQL (db)
* Banco sem uso de root para aplicações
* Controle de acesso ao banco por IP
* Porta 3306 liberada apenas para IPs autorizados

---

## 🧠 Fail2Ban (Arquitetura)

O projeto utiliza configuração modular:

```bash
/etc/fail2ban/jail.d/
```

Arquivos:

* `base.conf` → proteção SSH
* `web.conf` → proteção Apache
* `mysql.conf` → proteção MariaDB

Vantagens:

* Sem conflito entre scripts
* Independência entre serviços
* Escalável e reutilizável

---

## 🔁 Idempotência

Os scripts podem ser executados múltiplas vezes sem causar problemas:

* Não reinstalam pacotes já existentes
* Não duplicam configurações
* Não quebram serviços ativos

---

## ⚠️ Observações

* O script de banco pode remover acessos antigos (dependendo da escolha)
* O MariaDB precisa de log ativo para Fail2Ban funcionar corretamente
* O uso de `jail.d` evita conflitos com `jail.local`

---

## 🏷️ Versionamento

O projeto segue versionamento semântico:

```
MAJOR.MINOR.PATCH
```

* **MAJOR** → mudanças incompatíveis
* **MINOR** → novas funcionalidades
* **PATCH** → correções

### Versões atuais:

* **v1.0.0** → estrutura inicial
* **v1.1.0** → modularização (base, web, db)
* **v1.2.0** → controle de acesso por IP
* **v1.3.0** → integração com Fail2Ban (modular)

---

## 👨‍💻 Autor

Kauã — Infraestrutura / SysAdmin

---

## 📄 Licença

Uso livre para fins educacionais e profissionais.
