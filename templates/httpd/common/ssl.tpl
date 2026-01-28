<VirtualHost %httpd_ip%:%httpd_port%>
    ServerName %domain_idn%
    DirectoryIndex index.html

    DocumentRoot /usr/local/qweec/web/public
    <Directory /usr/local/qweec/web/public>
        AllowOverride All
        Options +Includes -Indexes +ExecCGI
    </Directory>

    Alias /errorpage/ /usr/local/qweec/web/public/errorpage/
    ErrorLog /dev/null
    CustomLog /dev/null common
    
    IncludeOptional /etc/httpd/conf.d/letsencrypt.inc
</VirtualHost>

