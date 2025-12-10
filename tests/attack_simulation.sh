#!/bin/bash

TARGET="https://localhost"
# Ignore self-signed certs
CURL_OPTS="-k -s -o /dev/null -w %{http_code}"

echo "Starting Attack Simulation against $TARGET"
echo "----------------------------------------"

# 1. Normal Request
echo "[1] Sending Normal Request..."
CODE=$(curl $CURL_OPTS "$TARGET/")
if [ "$CODE" == "200" ]; then
    echo "✅ Passed (200 OK)"
else
    echo "❌ Failed (Got $CODE)"
fi

# 2. SQL Injection
echo "[2] Sending SQL Injection Attack..."
CODE=$(curl $CURL_OPTS "$TARGET/?id=1'%20OR%20'1'='1")
if [ "$CODE" == "403" ]; then
    echo "✅ Blocked (403 Forbidden)"
else
    echo "❌ Failed (Got $CODE - Expected 403)"
fi

# 3. XSS Attack
echo "[3] Sending XSS Attack..."
CODE=$(curl $CURL_OPTS "$TARGET/?search=<script>alert(1)</script>")
if [ "$CODE" == "403" ]; then
    echo "✅ Blocked (403 Forbidden)"
else
    echo "❌ Failed (Got $CODE - Expected 403)"
fi

# 4. Bad User Agent (Scanner)
echo "[4] Sending Bad User-Agent (nikto)..."
CODE=$(curl $CURL_OPTS -A "nikto" "$TARGET/")
if [ "$CODE" == "403" ]; then
    echo "✅ Blocked (403 Forbidden)"
else
    echo "❌ Failed (Got $CODE - Expected 403)"
fi

# 5. Rate Limiting (Requires 'ab')
if command -v ab &> /dev/null; then
    echo "[5] Testing Rate Limiting (100 requests)..."
    ab -n 100 -c 10 -k $TARGET/ > /dev/null 2>&1
    # Check if subsequent request is blocked
    CODE=$(curl $CURL_OPTS "$TARGET/")
    echo "    Status after flood: $CODE (Might be 503 if limited)"
else
    echo "[5] 'ab' not found, skipping partial rate limit test."
fi

echo "----------------------------------------"
echo "Simulation Complete."
