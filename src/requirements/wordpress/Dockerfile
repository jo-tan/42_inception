FROM debian:buster

RUN apt-get update && apt-get install -y php-fpm php-mysql wget

RUN wget https://wordpress.org/latest.tar.gz && \
    tar -xzvf latest.tar.gz && \
    mv wordpress /var/www/html && \
    chown -R www-data:www-data /var/www/html

COPY conf/www.conf /etc/php/7.3/fpm/pool.d/www.conf

EXPOSE 9000

CMD ["php-fpm7.3", "-F"]

/*
FROM debian:bookworm

RUN apt-get update -y \
    && apt-get install -y gnupg2 wget lsb-release apt-transport-https ca-certificates \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list \
    && apt-get update -y \
    && apt-get install -y php8.2-fpm php8.2-mysql redis php-redis \
    && rm -rf /var/lib/apt/lists/*


# a command-line interface for WordPress, you can manage WordPress once it's downloaded
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

RUN apt-get update -y && apt-get install -y default-mysql-client mariadb-client
RUN wget https://wordpress.org/wordpress-6.2.tar.gz -P /var/www/html
RUN cd /var/www/html \
	&& tar -xzf /var/www/html/wordpress-6.2.tar.gz \
	&& rm /var/www/html/wordpress-6.2.tar.gz

# ensure that the web server(nginx) has the necessary permissions to read and execute the files within the web root directory
RUN chown -R www-data:www-data /var/www/*
RUN chmod -R 755 /var/www/*

EXPOSE 9000

COPY ./tools/wpscript.sh ./
RUN chmod +x ./wpscript.sh

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

ENTRYPOINT ["bash", "./wpscript.sh"]
*/