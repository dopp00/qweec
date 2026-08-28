server {
    %nginx_listen4%
    %nginx_listen6%
    server_name %domain_idn% %nginx_aliases%;

    return 301 https://$server_name$request_uri;

    access_log %access_log% combined;
    error_log %error_log% error;

    include /etc/nginx/conf.d/letsencrypt.inc;
    include /etc/nginx/includes/%user%/%domain_idn%.conf_*;
}

