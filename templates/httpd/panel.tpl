<VirtualHost %httpd_listen4% %httpd_listen6%>
    ServerName %domain_idn% %httpd_aliases%
    #SuexecUserGroup %user% %group%
    DirectoryIndex index.html

    DocumentRoot %docroot%
    <Directory %docroot%>
        AllowOverride All
        Options +Includes -Indexes -ExecCGI
        <Files ".user.ini">
            Require all denied
        </Files>
    </Directory>

    RewriteEngine On
    RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L,NE]

    Alias /errorpage/ /usr/local/qweec/web/public/errorpage/
    ErrorLog %error_log%
    CustomLog %access_log% combined
    CustomLog %bytes_log% bytes

    IncludeOptional /etc/httpd/conf.d/letsencrypt.inc
    IncludeOptional /etc/httpd/includes/%user%/%domain_idn%.conf_*
</VirtualHost>

