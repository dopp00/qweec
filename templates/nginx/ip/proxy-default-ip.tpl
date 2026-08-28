server {
    listen %nginx_ip%:%nginx_port% default_server;
    server_name  _;
    location / {
        proxy_pass http://%httpd_ip%:%httpd_port%;
   }
}

server {
    %nginx_listen4_quic_reuseport_default%
    %nginx_listen6_quic_reuseport_default%
    listen %nginx_ip%:%nginx_port_ssl% default_server;
    server_name  _;
    ssl_certificate     %ssl_pem%;
    ssl_certificate_key %ssl_key%;
    location / {
        proxy_pass https://%httpd_ip%:%httpd_port_ssl%;
   }
}

