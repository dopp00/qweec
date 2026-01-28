server {
    %nginx_listen4%
    %nginx_listen6%
    server_name %domain_idn% %nginx_aliases%;

    location / {
        proxy_pass http://%httpd_ip%:%httpd_port%;
        # do not proxy Upgrade over http2 for simple requests, but if need to use ws/wss - delete next line
        proxy_hide_header Upgrade;

        location ~* ^.+\.(%nginx_extentions%)$ {
            try_files  $uri @fallback;
            root       %docroot%;
            expires    max;
            access_log %access_log% combined;
            access_log %bytes_log% bytes;
        }
    }

    location @fallback {
        proxy_pass http://%httpd_ip%:%httpd_port%;
        proxy_hide_header Upgrade;
    }

    location ~ /\.(?!well-known\/) {
        deny all;
        return 404;
    }

    error_log %error_log% error;
    
    include /etc/nginx/conf.d/letsencrypt.inc;
    include /etc/nginx/includes/%user%/%domain_idn%.conf_*;

}

