proxy_cache_path /var/cache/nginx/proxy/%domain_idn% levels=2 keys_zone=%domain_idn%.proxy:10m inactive=60m max_size=128m;
server {
    %nginx_listen4%
    %nginx_listen6%
    server_name %domain_idn% %nginx_aliases%;

    location / {
        proxy_pass http://%httpd_ip%:%httpd_port%;
        proxy_hide_header Upgrade;  
        
        proxy_cache %domain_idn%.proxy;
        proxy_cache_valid 200 5m;
        proxy_cache_valid 301 302 10m;
        proxy_cache_valid 404 10m;
        proxy_cache_bypass $no_cache $cookie_session $http_x_update;
        proxy_no_cache $no_cache;
        set $no_cache 0;
        if ($request_uri ~* "/wp-admin/|/wp-json/|wp-.*.php|xmlrpc.php|/store.*|/cart.*|/my-account.*|/checkout.*|/user/|/admin/|/administrator/|/manager/|index.php") {
            set $no_cache 1;
        }
        if ($http_cookie ~* "comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_no_cache|wordpress_logged_in|woocommerce_items_in_cart|woocommerce_cart_hash|PHPSESSID") {
            set $no_cache 1;
        }
        if ($http_cookie ~ SESS) {
            set $no_cache 1;
        }

        location ~* ^.+\.(%nginx_extentions%)$ {
            try_files  $uri @fallback;
            root       %docroot%;
            expires    max;
            access_log %access_log% combined;
            access_log %bytes_log% bytes;
            proxy_cache off;
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

