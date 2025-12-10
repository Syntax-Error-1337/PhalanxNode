# PhalanxNode Security Policy

## Reporting a Vulnerability

Please report any security vulnerabilities to the maintainer via email.

## Defense Mechanisms

### Network Layer
- **Connection Limiting**: Limits concurrent connections per IP.
- **Rate Limiting**: Limits request rate per IP to prevent flood attacks.

### Application Layer
- **ModSecurity**: Inspects all incoming HTTP traffic.
- **OWASP CRS**: Blocks common attack vectors (SQLi, XSS, RCE, etc.).
- **Bot Detection**: Blocks known bad user agents and scanners.

### Headers
- **HSTS**: Enforces HTTPS.
- **CSP**: Mitigates XSS and data injection.
- **X-Frame-Options**: Prevents clickjacking.
