#!/bin/sh
# Build a CA bundle that trusts both the public CAs and the local ODK Central
# test stack. See issue #170.
#
# Do NOT point CURL_CA_BUNDLE at .devcontainer/odkc/certs/ca.crt on its own.
# That setting REPLACES libcurl's CA bundle instead of adding to it, so every
# other https request from R (CRAN, GitHub, ruodk.getodk.cloud) would fail
# certificate verification. This script concatenates the system bundle with
# the local CA, and the result is what CURL_CA_BUNDLE must name.
#
# Usage:  ca-bundle.sh [output-path]
# Prints the output path on success.
#
# The default output sits in this directory, not in certs/. The `certs` service
# writes certs/ as root, so an unprivileged user cannot add files there.
set -eu

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
out="${1:-$here/ca-bundle.pem}"
local_ca="$here/certs/ca.crt"

sys=""
for cand in /etc/ssl/certs/ca-certificates.crt /etc/pki/tls/certs/ca-bundle.crt; do
  if [ -r "$cand" ]; then
    sys="$cand"
    break
  fi
done
if [ -z "$sys" ]; then
  echo "ca-bundle.sh: no system CA bundle found" >&2
  exit 1
fi

if [ ! -r "$local_ca" ]; then
  echo "ca-bundle.sh: missing $local_ca" >&2
  echo "Start the test stack first so the \`certs\` service can mint it." >&2
  exit 1
fi

mkdir -p "$(dirname -- "$out")"
cat "$sys" "$local_ca" > "$out"
chmod 644 "$out"
echo "$out"
