FROM ubuntu:trusty

MAINTAINER Santiago Rodriguez <scollazo@gmail.com>

#Config files and some ideas taken from
# https://github.com/Epheo/docker-naxsi-proxy-waf/

RUN apt-get update

#Install nginx-naxsi from repos
RUN apt-get -y install nginx-naxsi 

#naxsi-ui is installed from sources, so we need dependencies
RUN apt-get install -y python-twisted-web python-geoip git

#Get naxsi-ui from source
RUN $(cd /usr/local/ && git clone https://github.com/nbs-system/naxsi.git && cd naxsi && git checkout 0.50 )

#Fix compatibility issues
RUN sed -i 's/error import NoResource/resource import NoResource/g'  /usr/local/naxsi/contrib/naxsi-ui/nx_extract.py

#Configuration files
ADD nginx/nginx.conf /etc/nginx/nginx.conf
ADD nginx/default /etc/nginx/sites-enabled/default
ADD naxsi-ui/naxsi-ui.conf /usr/local/naxsi/contrib/naxsi-ui/naxsi-ui.conf
RUN mkdir /etc/nginx/local-config
RUN mkdir /var/log/naxsi

#Change this and build the image to suit your needs by default, without needing to add parameters later
ENV LEARNING_MODE yes
ENV PROXY_REDIRECT_IP 12.34.56.78
ENV NAXSI_UI_PASSWORD test

#Ports
EXPOSE 80
EXPOSE 8081

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

