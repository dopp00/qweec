Alias /roundcube16%web_randomlink% /var/lib/roundcube16
<Directory /var/lib/roundcube16>
    <IfModule mod_authz_core.c>
        Require all granted
    </IfModule>
    <IfModule !mod_authz_core.c>
        Order Deny,Allow
        Deny from all
        Allow from all
    </IfModule>
</Directory>

