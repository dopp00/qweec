name: mariadb-5.5-podman
services:
  mariadb-5.5:
    image: mariadb:5.5
    container_name: mariadb-5.5
    restart: on-failure:4
    environment:
      MYSQL_ROOT_PASSWORD: "%superuser_password%"
      # MARIADB_ROOT_PASSWORD: "%superuser_password%"
    ports:
      - "%container_hostport%:3306"
    volumes:
      - "/etc/mariadb-5.5.conf.d:/etc/mysql/conf.d"
      - "/var/lib/mariadb-5.5:/var/lib/mysql"
