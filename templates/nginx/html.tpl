server {
    %nginx_listen4%
    %nginx_listen6%
    server_name %domain_idn% %nginx_aliases%;
    index       index.php index.html;
    root        %docroot%;

    location / {
        location ~* ^.+\.(%nginx_extentions%)$ {
            expires max;
        }
    }

    location ~ [^/]\.php(/|$) {
        types { } default_type "text/html";
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
