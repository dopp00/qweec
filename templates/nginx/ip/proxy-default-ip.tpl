server {
    listen %nginx_ip%:%nginx_port% default_server;
    server_name  _;
    location / {
        proxy_pass http://%httpd_ip%:%httpd_port%;
   }
}

server {
    listen %nginx_ip%:%nginx_ssl_port% default_server;
    server_name  _;
    ssl_certificate     %ssl_pem%;
    ssl_certificate_key %ssl_key%;
    location / {
        proxy_pass https://%httpd_ip%:%httpd_ssl_port%;
   }
}

