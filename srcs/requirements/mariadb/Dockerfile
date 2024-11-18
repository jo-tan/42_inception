# use debian as the base image
FROM debian:bullseye

# install/update MariaDB and other dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y mariadb-server mariadb-client procps

# copy the provided config file from host to the container
COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

#set permissions to files
RUN mkdir -p /var/run/mysqld
RUN mkdir -p /var/lib/mysql
RUN chown mysql:mysql /var/run/mysqld/
RUN chmod -R 755 /var/run/mysqld/
RUN chown mysql:mysql /var/lib/mysql/
RUN chmod -R 755 /var/lib/mysql/

EXPOSE 3306

COPY ./tools/dbscript.sh ./
RUN chmod +x ./dbscript.sh

#defin entrypoint command to run when container starts
ENTRYPOINT ["bash", "./dbscript.sh"]
