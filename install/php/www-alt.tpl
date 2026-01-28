[www]
listen = %socket%
listen.owner = qwuser
listen.group = %webuser%
listen.mode = 0660
user = qwuser
group = qwuser
chdir = /

pm = dynamic
pm.max_children = 8
pm.start_servers = 1
pm.min_spare_servers = 1
pm.max_spare_servers = 1
pm.max_requests = 400
pm.process_idle_timeout = 10s

;php_admin_value[sendmail_path] = /usr/sbin/sendmail -t -i -f www@domain.local
php_admin_value[open_basedir] = /var/lib/phpmyadmin52:/var/lib/roundcube16:/var/lib/php-fpm-alt:/usr/local/qweec/web/public:/var/tmp:/tmp:/bin:/usr/bin:/usr/share
php_admin_value[upload_tmp_dir] = /tmp
php_admin_value[session.save_path] = /var/lib/php-fpm-alt/session%phpver%

;env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/bin:/bin
env[TMP] = /tmp
env[TEMP] = /tmp
env[TMPDIR] = /tmp