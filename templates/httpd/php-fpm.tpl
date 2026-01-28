<VirtualHost %httpd_listen4% %httpd_listen6%>
    ServerName %domain_idn% %httpd_aliases%
    #SuexecUserGroup %user% %group%
    DirectoryIndex index.php index.html
    ScriptAlias /cgi-bin/ %home%/%user%/cgi-bin/%domain_idn%

    DocumentRoot %docroot%
    <Directory %docroot%>
        AllowOverride All
        Options +Includes -Indexes +ExecCGI
        <Files ".user.ini">  
            Require all denied
        </Files>
    </Directory>

    <FilesMatch \.php$>
        SetHandler "proxy:%backendlistener%|fcgi://localhost"
    </FilesMatch>
    # workaround for missing Authorization header under CGI/FastCGI Apache:
    # $_SERVER[PHP_AUTH_*] variables become available in phpif the client sends the Authorization header.
    SetEnvIf Authorization .+ HTTP_AUTHORIZATION=$0
    # default php setting for Authorization
    # SetEnvIf Authorization "(.*)" HTTP_AUTHORIZATION=$1

    Alias /errorpage/ /usr/local/qweec/web/public/errorpage/
    ErrorLog %error_log%
    CustomLog %access_log% combined
    CustomLog %bytes_log% bytes

    IncludeOptional /etc/httpd/conf.d/letsencrypt.inc
    IncludeOptional /etc/httpd/includes/%user%/%domain_idn%.conf_*
</VirtualHost>

