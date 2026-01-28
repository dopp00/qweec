Alias /phpmyadmin52%web_randomlink% /var/lib/phpmyadmin52
<Directory /var/lib/phpmyadmin52>
   AddDefaultCharset UTF-8
   Satisfy All
   <IfModule mod_authz_core.c>
        Require all granted
    </IfModule>
    <IfModule !mod_authz_core.c>
        Order allow,deny
        Allow from all
    </IfModule>
</Directory>

<Files config.inc.php>
    <IfModule mod_authz_core.c>
        Require all denied
    </IfModule>
    <IfModule !mod_authz_core.c>
        Order allow,deny
        Deny from all
    </IfModule>
</Files>

<Directory /var/lib/phpmyadmin52/conf.d>
    <IfModule mod_authz_core.c>
        Require all denied
    </IfModule>
    <IfModule !mod_authz_core.c>
        Order allow,deny
        Deny from all
    </IfModule>
</Directory>

<Directory /var/lib/phpmyadmin52/libraries>
    <IfModule mod_authz_core.c>
        Require all denied
    </IfModule>
    <IfModule !mod_authz_core.c>
        Order allow,deny
        Deny from all
    </IfModule>
</Directory>

<Directory /var/lib/phpmyadmin52/templates>
    <IfModule mod_authz_core.c>
        Require all denied
    </IfModule>
    <IfModule !mod_authz_core.c>
        Order allow,deny
        Deny from all
    </IfModule>
</Directory>

<Directory /var/lib/phpmyadmin52/setup/>
    <IfModule mod_authz_core.c>
        Require local
    </IfModule>
    <IfModule !mod_authz_core.c>
        Order Deny,Allow
        Deny from all
        Allow from 127.0.0.1
        Allow from ::1
    </IfModule>
</Directory>
<Directory /var/lib/phpmyadmin52/setup/lib>
    <IfModule mod_authz_core.c>
        Require all denied
    </IfModule>
    <IfModule !mod_authz_core.c>
        Order allow,deny
        Deny from all
    </IfModule>
</Directory>
<Directory /var/lib/phpmyadmin52/setup/frames>
        <IfModule mod_authz_core.c>
        Require all denied
    </IfModule>
    <IfModule !mod_authz_core.c>
        Order allow,deny
        Deny from all
    </IfModule>
</Directory>
           
# # this prevents mod_security at phpMyAdmin directories from filtering SQL etc. may break mod_security.
#<IfModule mod_security.c>
#    <Directory /var/lib/phpmyadmin52/>
#        SecRuleInheritance Off
#    </Directory>
#</IfModule>