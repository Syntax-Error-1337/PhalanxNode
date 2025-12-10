# 🛡️ PhalanxNode

<div align="center">

![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Nginx](https://img.shields.io/badge/nginx-%23009639.svg?style=for-the-badge&logo=nginx&logoColor=white)
![ModSecurity](https://img.shields.io/badge/ModSecurity-v3-blue?style=for-the-badge)
![OWASP CRS](https://img.shields.io/badge/OWASP_CRS-v4-orange?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)

**A production-ready, Dockerized security suite featuring NGINX, ModSecurity v3, and the OWASP Core Rule Set.**

[Features](#-features) •
[Quick Start](#-quick-start) •
[Configuration](#%EF%B8%8F-configuration) •
[Testing](#-testing--verification) •
[Security](#-security-policy)

</div>

---

## 📖 Overview

**PhalanxNode** provides a hardened web server stack designed to protect against modern web threats. It compiles NGINX from source with the ModSecurity v3 connector and integrates the OWASP Core Rule Set (CRS) in Strict Mode.

This project is built to be **defensive-only**, ensuring legitimate traffic flows smoothly while malicious actors (bots, SQLi, XSS, floods) are blocked at the edge.

> **Why "PhalanxNode"?**
> The name combines **Phalanx**, the ancient Greek military formation of heavy infantry standing shoulder-to-shoulder in an unbreakable line, with **Node**, representing a single unit in a modern network infrastructure. It symbolizes a hardened, disciplined defense for your server.

## ✨ Features

- **🔥 WAF Protection**: ModSecurity v3 + OWASP CRS v4 (Strict Mode).
- **🛡️ DDoS Mitigation**:
    - **L3/L4**: Connection limiting & request rate limiting per IP.
    - **L7**: Slowloris protection (timeouts), body size limits.
- **🤖 Bot Detection**: Blocks known bad User-Agents and scanners.
- **🔒 Hardened NGINX**:
    - Modern SSL/TLS cipher suites (TLS 1.2+).
    - Security Headers (HSTS, CSP, X-Frame-Options).
    - Hidden server tokens.
- **🐳 Dockerized**: Multi-stage build based on Alpine Linux for a minimal footprint.

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- `openssl` (for generating test certificates)

### 1. Installation

Clone the repository and navigate to the directory:

```bash
git clone https://github.com/yourusername/phalanxnode.git
cd phalanxnode
```

### 2. Generate SSL Certificates
For local development, generate self-signed certificates (or mount your own):

```bash
chmod +x tests/generate_certs.sh
./tests/generate_certs.sh
```
*Creates `certs/server.key` and `certs/server.crt`.*

### 3. Build & Run
Launch the security stack:

```bash
cd docker
docker-compose up -d --build
```

Access the server at **`https://localhost`**.
*(Accept the security warning for self-signed certs)*

## 📂 Project Structure

```tree
.
├── Local Certs
│   └── certs/              # SSL Certificates
├── Docker Configuration
│   ├── docker/Dockerfile   # Multi-stage build (NGINX + ModSec)
│   └── docker/docker-compose.yml
├── WAF Configuration
│   ├── modsecurity/
│   │   ├── modsecurity.conf # Base WAF config
│   │   ├── crs-setup.conf   # OWASP CRS setup
│   │   └── rules/          # Custom Rules
│   │       ├── REQUEST-900-DENY-FLOOD.conf
│   │       ├── REQUEST-910-BOT-DETECTION.conf
│   │       └── RESPONSE-999-CUSTOM-SECURITY.conf
├── NGINX Configuration
│   ├── nginx/nginx.conf    # Global tuning & hardening
│   └── nginx/conf.d/       # Server blocks
└── Verification
    ├── tests/attack_simulation.sh
    └── SECURITY.md
```

## ⚙️ Configuration

### Tuning Rate Limits
Edit `nginx/nginx.conf` and `nginx/conf.d/default.conf`:

```nginx
# Global usage (nginx.conf)
limit_req_zone $binary_remote_addr zone=ip_rate:10m rate=10r/s;

# Server block usage (default.conf)
limit_req zone=ip_rate burst=20 delay=10;
```

### Adjusting WAF Rules
- **Paranoia Level**: Edit `modsecurity/crs-setup.conf` (Default: 1).
- **Custom Rules**: Add new `.conf` files to `modsecurity/rules/`.

## 🧪 Testing & Verification

We provide a script to simulate attacks (SQLi, XSS, Flood) and verify the WAF is working.

```bash
# Run the attack simulation
./tests/attack_simulation.sh
```

**Expected Output:**
- ✅ Normal Request: **200 OK**
- ✅ SQL Injection: **403 Forbidden**
- ✅ XSS Attack: **403 Forbidden**
- ✅ Bot Scanner: **403 Forbidden**

## 🔐 Security Policy

See [SECURITY.md](SECURITY.md) for details on the security policy and vulnerability reporting.

## 🤝 Contributing

Contributions are welcome! Please fork the repository and submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

Distributed under the MIT License.
