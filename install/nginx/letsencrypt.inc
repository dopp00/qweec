    location ^~ /.well-known/acme-challenge/ {
        allow all;
        try_files $uri =404;
        alias /usr/local/qweec/web/public/.well-known/acme-challenge/;
        default_type text/plain;
        add_header Cache-Control 'must-revalidate';
    }