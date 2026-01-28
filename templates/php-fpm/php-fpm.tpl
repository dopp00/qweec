[%domain_idn%]
listen = %socket%
listen.owner = %user%
listen.group = %webuser%
listen.mode = 0660
user = %user%
group = %user%

pm = ondemand
pm.max_children = 5
pm.max_requests = 4000
pm.process_idle_timeout = 10s
pm.status_path = /status

php_admin_value[open_basedir] = %docroot%:/home/%user%/cgi-bin/%domain_idn%:/home/%user%/tmp:/usr/local/qweec/web/public:/var/tmp:/tmp:/bin:/usr/bin:/usr/share
php_admin_value[upload_tmp_dir] = /home/%user%/tmp
php_admin_value[session.save_path] = /home/%user%/tmp
php_admin_value[sendmail_path] = /usr/sbin/sendmail -t -i -f admin@%domain_idn%

env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /home/%user%/tmp
env[TMPDIR] = /home/%user%/tmp
env[TEMP] = /home/%user%/tmp
