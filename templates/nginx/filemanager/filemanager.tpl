location /fm_%user%/ {
    alias /home/%user%/fm/;
    try_files $uri $uri/ =404;
    location ~ ^/fm_%user%/driver\.php$ {
        try_files driver.php =404;
        fastcgi_index index.php;
        include       fastcgi_params;
        fastcgi_param HTTP_EARLY_DATA $rfc_early_data if_not_empty;
        fastcgi_param SCRIPT_FILENAME $request_filename;
        fastcgi_pass  %backendlistener%;
    }
    location ~ ^/fm_%user%/(.*\.php)$ {
        try_files index.php =404;
        fastcgi_index index.php;
        include       fastcgi_params;
        fastcgi_param HTTP_EARLY_DATA $rfc_early_data if_not_empty;
        fastcgi_param SCRIPT_FILENAME $request_filename;
        fastcgi_pass  %backendlistener%;
    }
}
