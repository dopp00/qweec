location /roundcube16%web_randomlink%/ {
    alias /var/lib/roundcube16/;
    try_files $uri $uri/ =404;

    location ~ /(config|temp|logs) { return 404; }

    location ~ ^/roundcube16%web_randomlink%/(.*\.php)$ {
        # alias /var/lib/roundcube16/$1;
        try_files $uri =404;
        fastcgi_index index.php;
        include       fastcgi_params;
        fastcgi_param HTTP_EARLY_DATA $rfc_early_data if_not_empty;
        fastcgi_param SCRIPT_FILENAME $request_filename;
        fastcgi_pass %backendlistener%;
    }
    location ~* ^/roundcube16%web_randomlink%/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
        alias /var/lib/roundcube16/$1;
    }
}
