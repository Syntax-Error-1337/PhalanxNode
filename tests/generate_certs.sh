#!/bin/bash

# Resolve the project root assuming script is in tests/
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CERT_DIR="$PROJECT_ROOT/certs"
DOMAIN="localhost"

mkdir -p $CERT_DIR

if [ -f "$CERT_DIR/server.key" ]; then
    echo "Certificates already exist in $CERT_DIR"
    exit 0
fi

echo "Generating Self-Signed Certificates for $DOMAIN..."

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout $CERT_DIR/server.key \
  -out $CERT_DIR/server.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=$DOMAIN"

echo "✅ Certificates generated in $CERT_DIR"
