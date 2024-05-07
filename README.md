# Overview
This is a shell script that can be set in cron to reset wireguard when a DNS record changes.  It stores an ip address memory in a file, and then regularly checks for updates to that address.

# Installation
Download file, and add to crontab
##
Make executable
```chmod +x check_dns_and_restart_wg.sh```

## Add to crontab
```sudo crontab -e```

Add (for hourly)
```
0 * * * * /bin/bash /root/check_dns_and_restart_wg.sh
```
