#!/bin/bash

# if error stop script
set -e

# binary full paths
AWK=$(which awk)
OPENSSL=$(which openssl)
ID=$(which id)
LSOF=$(which lsof)
SHORT=$(which sort)
UNIQ=$(which uniq)
TR=$(which tr)
GREP=$(which grep)
SUDO=$(which sudo)
ECHO=$(which echo)
PS=$(which ps)
WC=$(which wc)

# check root privs
if [[ $($ID -u) -ne 0 ]]; then
    $ECHO "[error] Please run as root";
    exit 1;
fi

# check os version
if [ -f "/etc/os-release" ]; then
  os_version=$($AWK -F'=' '/PRETTY_NAME/ {print $2}' /etc/os-release | $AWK -F'"' '{print $2}');
  $ECHO "[info] OS Version: ${os_version}";
else
  $ECHO "[info] Can not determine OS: ${os_version}";
fi

# check openssl version
$ECHO "[info] Checking OpenSSL version installed"
if [ -f "$OPENSSL" ]; then
  openssl_version=$($OPENSSL version);
  if [[ $($ECHO -n $openssl_version | $GREP -i -E "^OpenSSL 3.0.[0-6]") != '' ]]; then
    $ECHO "[critical] Vulnerable version found: ${openssl_version}";
  else
    $ECHO "[info] Secure version installed: ${openssl_version}";
  fi
else
  $ECHO "[info] OpenSSL not found";
fi

# check processes with vulnerable OpenSSL dynamic library loaded
$ECHO "[info] Checking system processes with vulnerable OpenSSL library loaded (dynamic linked)";
vulnerable_processes=$($SUDO $LSOF -n 2>/dev/null | $GREP -E 'libssl3.so|libcrypto.so.3' | $AWK '{print $2}' | $SHORT -n | $UNIQ);
if [[ $($ECHO -n vulnerable_processes | $WC -l) -ge 0 ]]; then
  $ECHO "[critical] Processes using vulnerable OpenSSL version (dynamic library loaded)";
  $PS -o '%p %a' $vulnerable_processes;
fi
