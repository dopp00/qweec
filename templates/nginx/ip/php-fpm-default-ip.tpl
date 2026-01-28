server {
    listen %nginx_ip%:%nginx_port% default_server;
    server_name _;

    root /usr/local/qweec/web/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ =404;

        location ~* \.php$ {
            try_files $uri =404;
            fastcgi_intercept_errors on;
            fastcgi_index index.php;
            include       fastcgi_params;
            fastcgi_param HTTP_EARLY_DATA $rfc_early_data if_not_empty;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_pass  %backendlistener%;
        }
    }

   include /etc/nginx/conf.d/phpmyadmin52.inc;
   include /etc/nginx/conf.d/roundcube16.inc;
   include /etc/nginx/fm/*.inc;
}

server {
    listen %nginx_ip%:%nginx_ssl_port% ssl default_server;
    server_name _;
    ssl_certificate     %ssl_pem%;
    ssl_certificate_key %ssl_key%;
    
    root /usr/local/qweec/web/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ =404;

        location ~* \.php$ {
            try_files $uri =404;
            fastcgi_intercept_errors on;
            fastcgi_index index.php;
            include       fastcgi_params;
            fastcgi_param HTTP_EARLY_DATA $rfc_early_data if_not_empty;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_pass  %backendlistener%;
        }
    }

    include /etc/nginx/conf.d/phpmyadmin52.inc;
    include /etc/nginx/conf.d/roundcube16.inc;
    include /etc/nginx/fm/*.inc;
}

