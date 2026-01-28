[fm_%user%]
listen = %socket%
listen.owner = %user%
listen.group = %webuser%
listen.mode = 0660
user = %user%
group = %user%

pm = dynamic
pm.max_children = 1
pm.start_servers = 1
pm.min_spare_servers = 1
pm.max_spare_servers = 1
pm.max_requests = 400
pm.process_idle_timeout = 10s

php_admin_value[open_basedir] = /home/%user%:/usr/local/qweec/web/public:/usr/bin:/bin
php_admin_value[upload_tmp_dir] = /home/%user%/tmp
php_admin_value[session.save_path] = /home/%user%/tmp
php_admin_value[sendmail_path] = 

env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/bin:/bin
env[TMP] = /home/%user%/tmp
env[TMPDIR] = /home/%user%/tmp
env[TEMP] = /home/%user%/tmp