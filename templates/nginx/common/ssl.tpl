server {
    listen      %nginx_ip%:%nginx_port%;
    server_name %domain_idn%;
    index       index.html;
    root        /usr/local/qweec/web/public;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ [^/]\.php(/|$) {
        types { } default_type "text/html";
    }

    location ~ /\.(?!well-known\/) {
        deny all;
        return 404;
    }

    location /errorpage/ { alias /usr/local/qweec/web/public/errorpage/; }
    access_log off;
    error_log  /dev/null crit;
    
    include /etc/nginx/conf.d/letsencrypt.inc;
}
