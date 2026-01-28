Alias /fm_%user% /home/%user%/fm
<Directory /home/%user%/fm/>
    Order Deny,Allow
    Deny from all
    Allow from all
    Options -Indexes +SymLinksIfOwnerMatch
    <IfModule rewrite_module>
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteCond %{REQUEST_URI} !^/fm_%user%/driver.php
        RewriteRule ^.*$ /index.php [L,QSA]
    </IfModule>
    <FilesMatch \.php$>
        SetHandler "proxy:%backendlistener%|fcgi://localhost"
    </FilesMatch>
</Directory>
