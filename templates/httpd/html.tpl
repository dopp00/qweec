<VirtualHost %httpd_listen4% %httpd_listen6%>
    ServerName %domain_idn% %httpd_aliases%
    #SuexecUserGroup %user% %group%
    DirectoryIndex index.html
    ScriptAlias /cgi-bin/ %home%/%user%/cgi-bin/%domain_idn%

    DocumentRoot %docroot%
    <Directory %docroot%>
        AllowOverride All
        Options +Includes -Indexes +ExecCGI
    </Directory>

    Alias /errorpage/ /usr/local/qweec/web/public/errorpage/
    ErrorLog %error_log%
    CustomLog %access_log% combined
    CustomLog %bytes_log% bytes

    IncludeOptional /etc/httpd/conf.d/letsencrypt.inc
    IncludeOptional /etc/httpd/includes/%user%/%domain_idn%.conf_*
</VirtualHost>

