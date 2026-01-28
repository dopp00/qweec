name: mariadb-11.4-podman
services:
  mariadb-11.4:
    image: mariadb:11.4
    container_name: mariadb-11.4
    restart: on-failure:4
    environment:
      # MYSQL_ROOT_PASSWORD: "%superuser_password%"
      MARIADB_ROOT_PASSWORD: "%superuser_password%"
    ports:
      - "%container_hostport%:3306"
    volumes:
      - "/etc/mariadb-11.4.conf.d:/etc/mysql/conf.d"
      - "/var/lib/mariadb-11.4:/var/lib/mysql"
