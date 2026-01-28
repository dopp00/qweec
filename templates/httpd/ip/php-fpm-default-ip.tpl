%listen_addresses%

<VirtualHost %httpd_ip%:%httpd_port%>
    #ServerName %httpd_ip%
    #SuexecUserGroup %rgroups% %rgroups%
    DirectoryIndex index.php index.html

    DocumentRoot /usr/local/qweec/web/public
    <Directory /usr/local/qweec/web/public>
        AllowOverride All
        Options +Includes -Indexes +ExecCGI
    </Directory>

    <FilesMatch \.php$>
        SetHandler "proxy:%backendlistener%|fcgi://localhost"
    </FilesMatch>
    SetEnvIf Authorization .+ HTTP_AUTHORIZATION=$0

    IncludeOptional /etc/httpd/conf.d/phpmyadmin52.inc
    IncludeOptional /etc/httpd/conf.d/roundcube16.inc
    IncludeOptional /etc/httpd/fm/*.inc
</VirtualHost>

<VirtualHost %httpd_ip%:%httpd_ssl_port%>
    #ServerName %httpd_ip%
    #SuexecUserGroup %rgroups% %rgroups%
    DirectoryIndex index.php index.html

    DocumentRoot /usr/local/qweec/web/public
    <Directory /usr/local/qweec/web/public>
        AllowOverride All
        SSLRequireSSL
        Options +Includes -Indexes +ExecCGI
    </Directory>

    <FilesMatch \.php$>
        SetHandler "proxy:%backendlistener%|fcgi://localhost"
    </FilesMatch>
    SetEnvIf Authorization .+ HTTP_AUTHORIZATION=$0

    SSLEngine on
    SSLVerifyClient none
    SSLCertificateFile %ssl_pem%
    SSLCertificateKeyFile %ssl_key%
    
    IncludeOptional /etc/httpd/conf.d/phpmyadmin52.inc
    IncludeOptional /etc/httpd/conf.d/roundcube16.inc
    IncludeOptional /etc/httpd/fm/*.inc
</VirtualHost>


