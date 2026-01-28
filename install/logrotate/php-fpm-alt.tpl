/var/log/php-fpm-alt/*%phpver%.log {
    weekly
    rotate 2
    missingok
    notifempty
    sharedscripts
    delaycompress
    postrotate
        /usr/bin/kill -SIGUSR1 $(cat /run/php-fpm-alt%phpver%/php-fpm.pid 2>/dev/null) 2>/dev/null || true
    endscript
}
