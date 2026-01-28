fastcgi_cache_path /var/cache/nginx/fastcgi/%domain_idn% levels=1:2 keys_zone=%domain_idn%.fastcgi:10m inactive=30m max_size=128m;
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
            fastcgi_pass  %backendlistener%;

            # microcache
            add_header X-FastCGI-Cache $upstream_cache_status;
            fastcgi_cache %domain_idn%.fastcgi;
            fastcgi_cache_lock on;
            fastcgi_cache_valid 200 5m; # 5 minutes
            fastcgi_cache_use_stale updating;
            fastcgi_pass_header Set-Cookie;
            fastcgi_pass_header Cookie;
            fastcgi_ignore_headers Cache-Control Expires Set-Cookie;
            fastcgi_cache_bypass $no_cache;
            fastcgi_no_cache $no_cache;
            fastcgi_hide_header 'X-Powered-By';
            set $no_cache 0;
            if ($request_method = POST) { set $no_cache 1; }
            if ($request_method !~ ^(GET|HEAD)$) { set $no_cache "1"; }
            if ($query_string != "") { set $no_cache 1; }
            if ($request_uri ~* "/wp-admin") { set $no_cache 1; }
            if ($request_uri ~* "/admin") { set $no_cache 1; }
            if ($request_uri ~* "/user") { set $no_cache 1; }

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
