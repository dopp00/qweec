    <IfModule alias_module>
        Alias /.well-known/acme-challenge/ /usr/local/qweec/web/public/.well-known/acme-challenge/
        <Directory /usr/local/qweec/web/public>
            AllowOverride All
            Options +Includes -Indexes +ExecCGI
        </Directory>
    </IfModule>