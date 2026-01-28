server {
    %nginx_listen4%
    %nginx_listen6%
    server_name %domain_idn% %nginx_aliases%;
    index       index.php index.html;
    root        %docroot%;

    location / {
        location ~* ^.+\.(%nginx_extentions%)$ {
            expires max;
            fastcgi_hide_header "Set-Cookie";
        }

        location ~ [^/]\.php(/|$) {
            try_files $uri =404;
            fastcgi_intercept_errors on;
            fastcgi_index index.php;
            include       fastcgi_params;
            fastcgi_param HTTP_EARLY_DATA $rfc_early_data if_not_empty;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            # might be better than above to avoid opcodes cahing of symlinks, needs testing
            # fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
            fastcgi_pass  %backendlistener%;
        }
    }

    location ~ /\.(?!well-known\/) {
        deny all;
        return 404;
    }

    location /errorpage/ { alias /usr/local/qweec/web/public/errorpage/; }

    error_log  %error_log% error;
    access_log %access_log% combined;
    access_log %bytes_log% bytes;
    
    include /etc/nginx/conf.d/letsencrypt.inc;
    include /etc/nginx/includes/%user%/%domain_idn%.conf_*;

}
