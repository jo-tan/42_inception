FROM debian:bookworm

#this install nginx/openssl and remove the apt cache to reduce image size.
RUN apt -y update && apt install -y nginx && apt install openssl -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#create a dir for the ssl certificate
RUN mkdir /etc/nginx/ssl

#generate ssl certif
RUN openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
       -out /etc/nginx/ssl/inception.crt \
       -keyout /etc/nginx/ssl/inception.key \
       -subj "/C=FR/ST=Paris/L=Paris/O=42 School/OU=jo-tan/CN=jo-tan.42.fr/"

#copy nginx configuration file
COPY ./conf/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /run/nginx

#expose port
EXPOSE 443 80

#define cmd to run when the container starts: -g "daemon off" ensure NGINX runs in foreground for Docker Container to stay alive
CMD ["nginx", "-g", "daemon off;"]