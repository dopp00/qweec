name: mysql-8.4-podman
services:
  mysql-8.4:
    image: mysql:8.4
    container_name: mysql-8.4
    restart: on-failure:4
    environment:
      MYSQL_ROOT_PASSWORD: "%superuser_password%"
    ports:
      - "%container_hostport%:3306"
    volumes:
      - "/etc/mysql-8.4.conf.d:/etc/mysql/conf.d"
      - "/var/lib/mysql-8.4:/var/lib/mysql"
