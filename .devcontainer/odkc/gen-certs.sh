#!/bin/sh
# Mint a throwaway CA + server certificate for the ODK Central test stack.
#
# Why this exists: ODK Central refuses HTTP Basic auth over plain HTTP
# (getodk/central-backend lib/http/preprocessors.js -> Problem.user.httpsOnly),
# and ruODK authenticates with httr::authenticate() -> Basic. So the test API
# must be reached over TLS. nginx terminates this self-signed cert and sets
# X-Forwarded-Proto, which is the case preprocessors.js expects behind a proxy.
#
# openssl recipe follows central-backend/test/bin/docker-postgres.sh --ssl,
# with proper CA extensions and a longer validity so a devcontainer can sit on
# the certs for a while. Nothing here is a real secret: the CA is local-only,
# the key never leaves .devcontainer/odkc/certs/ (gitignored), and it only
# vouches for "localhost".
#
# Regenerate with:  rm -rf .devcontainer/odkc/certs && docker compose up certs
set -eu

CERTS="${CERTS_DIR:-/certs}"
mkdir -p "$CERTS"

# This script runs as root inside a container, so $CERTS would otherwise be
# root-owned on the bind mount. The unprivileged host user then cannot write
# ca-bundle.pem next to the certs, or clear the directory to regenerate. The
# directory holds only a throwaway localhost CA, so give it the write bit.
# Applied before the early return below so a re-run repairs the mode too.
chmod 777 "$CERTS"

cd "$CERTS"

if [ -s ca.crt ] && [ -s server.crt ] && [ -s server.key ]; then
  echo "[gen-certs] certs already present in $CERTS, leaving them alone."
  exit 0
fi

echo "[gen-certs] minting a local CA and a localhost server cert in $CERTS .."

openssl genrsa -out ca.key 2048 2>/dev/null
openssl req -x509 -new -nodes \
  -key ca.key -sha256 -days 825 \
  -subj "/CN=ruODK local test CA" \
  -addext "basicConstraints=critical,CA:TRUE" \
  -addext "keyUsage=critical,keyCertSign,cRLSign" \
  -out ca.crt

openssl genrsa -out server.key 2048 2>/dev/null
openssl req -new \
  -key server.key \
  -subj "/CN=localhost" \
  -out server.csr

openssl x509 -req \
  -in server.csr \
  -CA ca.crt -CAkey ca.key -CAcreateserial \
  -sha256 -days 825 \
  -out server.crt \
  -extfile /dev/stdin <<'EOF'
basicConstraints = critical, CA:FALSE
keyUsage        = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName  = DNS:localhost, IP:127.0.0.1, IP:::1
EOF

rm -f server.csr ca.srl

# R only reads ca.crt (via the merged bundle); nginx's master process reads the
# key as root. World-readable certs, private keys root-only.
chmod 644 ca.crt server.crt
chmod 600 ca.key server.key

echo "[gen-certs] done."
