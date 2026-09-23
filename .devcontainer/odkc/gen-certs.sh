#!/bin/sh
# Mint a throwaway CA + server certificate for the ODK Central test stack.
#
# Why this exists: ODK Central refuses HTTP Basic auth over plain HTTP
# (getodk/central-backend lib/http/preprocessors.js -> Problem.user.httpsOnly),
# and ruODK authenticates with httr::authenticate() -> Basic. So the test API
# must be reached over TLS. nginx terminates this self-signed cert and sets
# X-Forwarded-Proto, which is the case preprocessors.js expects.
#
# openssl recipe follows central-backend/test/bin/docker-postgres.sh --ssl,
# with proper CA extensions and a longer validity so a devcontainer can sit on
# the certs for a while. Nothing here is a real secret: the CA is local-only,
# the key never leaves odkc/certs/ (gitignored), and it only vouches for
# "localhost".
#
# Regenerate with:  rm -rf .devcontainer/odkc/certs && docker compose up certs
set -eu

CERTS="${CERTS_DIR:-/certs}"
mkdir -p "$CERTS"
cd "$CERTS"

if [ -s ca.crt ] && [ -s server.crt ] && [ -s server.key ]; then
  echo "[gen-certs] certs already present in $CERTS, leaving them alone."
else
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
  echo "[gen-certs] done."
fi

# Ownership and modes, applied on every run so a re-run repairs them.
#
# This script runs as root in a container that writes onto a bind mount, so the
# files arrive root-owned. The key modes below are 600, which then makes them
# unreadable to the host user. `R CMD build` copies the whole package tree
# before it applies .Rbuildignore, so an unreadable file stops the build even
# though .devcontainer is excluded. Take the owner of the parent directory
# (the host user) and give the tree to them.
owner=$(stat -c '%u:%g' .. 2>/dev/null || echo "0:0")
chown -R "$owner" .
chmod 755 .

# R reads ca.crt through the merged bundle, and nginx's master process reads the
# key as root. Certificates world-readable, private keys owner-only.
chmod 644 ca.crt server.crt
chmod 600 ca.key server.key

echo "[gen-certs] ownership set to $owner."
