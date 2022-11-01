# Vulnerable-OpenSSL-3.x-Checker

This script ONLY checks if vulnerable version of OpenSSL3 is installed on the system and also check if runnig processes are using vulnerable OpenSSL3 library (linked dynamically)  

This script DO NOT check binaries built with static linking or SNAP packages, Flatpak, Go binaries...

One-Liner (Local execution)
```
wget -qO /tmp/openssl3-checker.sh https://raw.githubusercontent.com/jojaloca/Vulnerable-OpenSSL-3.x-Checker/main/openssl3-check.sh && chmod +x /tmp/openssl3-checker.sh && sudo /tmp/openssl3-checker.sh && rm /tmp/openssl3-checker.sh
```

One-Liner (Remote execution, SSH) Change user with your user and myip with your server ip or domain.
```
ssh -t user@myip "wget -qO /tmp/openssl3-checker.sh https://raw.githubusercontent.com/jojaloca/Vulnerable-OpenSSL-3.x-Checker/main/openssl3-check.sh && chmod +x /tmp/openssl3-checker.sh && sudo /tmp/openssl3-checker.sh && rm /tmp/openssl3-checker.sh"
```
