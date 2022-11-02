#!/bin/bash

# if error stop script
#set -e

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
FIND=$(which find)

REGEX='^OpenSSL 3.0.[0-6]'

# check root privs
if [[ $($ID -u) -ne 0 ]]; then
    $ECHO "[error] Please run as root";
    exit 1;
fi

# print hostname
$ECHO "[info] Hostname: $HOSTNAME";

# check os version
if [ -f "/etc/os-release" ]; then
  os_version=$($AWK -F'=' '/PRETTY_NAME/ {print $2}' /etc/os-release | $AWK -F'"' '{print $2}');
  $ECHO "[info] OS Version: ${os_version}";
else
  $ECHO "[info] Can not determine OS: ${os_version}";
fi

# check OpenSSL version
$ECHO "[info] Checking OpenSSL version installed (SO)"
if [ -f "$OPENSSL" ]; then
  openssl_version=$($OPENSSL version);
  if [[ $($ECHO -n $openssl_version | $GREP -i -E "$REGEX") != '' ]]; then
    $ECHO "[critical] Vulnerable version found in OS: ${openssl_version}";
  else
    $ECHO "[info] Secure version installed in OS: ${openssl_version}";
  fi
else
  $ECHO "[info] OpenSSL not found in OS";
fi

# search OpenSSL3 libraries in system
$ECHO "[info] Searching vulnerable OpenSSL library (System)"
libraries_found=$($FIND / -type f '(' -name "libcrypto3.so" -o -name "libcrypto.so.3" -o -name "libssl3.so" -o -name "libssl.so.3" -o -name "libssl3.a" -o -name "libssl.a.3" -o -name "libcrypto3.a" -o -name "libcrypto.a.3" ')' 2>/dev/null)
if [[ $($ECHO "$libraries_found" | $WC -w) -ge 0 ]]; then
  $ECHO "[critical] OpenSSL vulnerable library found in system";
  for file in $libraries_found; do
    $ECHO $file;
  done;
fi

# check processes with vulnerable OpenSSL3 dynamic library loaded
$ECHO "[info] Checking system processes with vulnerable OpenSSL library loaded (dynamic linked)";
vulnerable_processes=$($SUDO $LSOF -n 2>/dev/null | $GREP -E 'libssl3.so|libssl.so.3|libcrypto3.so|libcrypto.so.3' | $AWK '{print $2}' | $SHORT -n | $UNIQ);
if [[ $($ECHO -n vulnerable_processes | $WC -l) -ge 0 ]]; then
  $ECHO "[critical] Processes using vulnerable OpenSSL version (dynamic library loaded)";
  $PS -o '%p %a' $vulnerable_processes;
fi
