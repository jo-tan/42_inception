FROM debian:buster

RUN apt-get update && apt-get install -y nginx openssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=your_login.42.fr"

COPY conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]

/*
FROM debian:bookworm

#this install nginx/openssl and remove the apt cache to reduce image size.
RUN apt -y update && apt install -y nginx && apt install openssl -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#create a dir for the ssl certificate
RUN mkdir /etc/nginx/ssl

#generate certif
RUN openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
       -out /etc/nginx/ssl/inception.crt \
       -keyout /etc/nginx/ssl/inception.key \
       -subj "/C=FR/ST=Paris/L=Paris/O=42 School/OU=kdhrif/CN=kdhrif.42.fr/"

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /run/nginx

#expose port
EXPOSE 443 80

CMD ["nginx", "-g", "daemon off;"]
*/