
# works only with slash http://XX.XX.XX.XX/phpmyadmin52xxxx/

# slash is important in location and alias to prevent alias traversal hack
location /phpmyadmin52%web_randomlink%/ {
    alias /var/lib/phpmyadmin52/;
    try_files $uri $uri/ =404;

    location ~* /conf.d { return 403; }
    location ~ /(libraries|setup) { return 404; }

    location ~ ^/phpmyadmin52%web_randomlink%/(.*\.php)$ {
        # alias /var/lib/phpmyadmin52/$1;
        try_files $uri =404;
        fastcgi_index index.php;
        include       fastcgi_params;
        fastcgi_param HTTP_EARLY_DATA $rfc_early_data if_not_empty;
        fastcgi_param SCRIPT_FILENAME $request_filename;
        fastcgi_pass  %backendlistener%;
    }

    location ~* ^/phpmyadmin52%web_randomlink%/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
        alias /var/lib/phpmyadmin52/$1;
    }
}
