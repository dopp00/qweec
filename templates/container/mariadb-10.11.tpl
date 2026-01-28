# name: mariadb-10.11-podman
services:
  mariadb-10.11:
    image: mariadb:10.11
    container_name: mariadb-10.11
    restart: on-failure:4
    environment:
      # MYSQL_ROOT_PASSWORD: "%superuser_password%"
      MARIADB_ROOT_PASSWORD: "%superuser_password%"
    ports:
      - "%container_hostport%:3306"
    volumes:
      - "/etc/mariadb-10.11.conf.d:/etc/mysql/conf.d"
      - "/var/lib/mariadb-10.11:/var/lib/mysql"
