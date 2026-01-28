name: mysql-5.7-podman
services:
  mysql-5.7:
    image: mysql:5.7
    container_name: mysql-5.7
    restart: on-failure:4
    environment:
      MYSQL_ROOT_PASSWORD: "%superuser_password%"
    ports:
      - "%container_hostport%:3306"
    volumes:
      - "/etc/mysql-5.7.conf.d:/etc/mysql/conf.d"
      - "/var/lib/mysql-5.7:/var/lib/mysql"
