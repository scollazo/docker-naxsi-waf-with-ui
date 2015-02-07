FROM ubuntu:trusty

MAINTAINER Santiago Rodriguez <scollazo@gmail.com>

#Config files and some ideas taken from
# https://github.com/Epheo/docker-naxsi-proxy-waf/

#Install needed packages from repos
RUN apt-get update &&\
    DEBIAN_FRONTEND=noninteractive apt-get install -y nginx-naxsi python-twisted-web python-geoip git 


#Get naxsi-ui from source
RUN $(cd /usr/local/ && git clone https://github.com/nbs-system/naxsi.git && cd naxsi && git checkout 0.50 )

#Fix compatibility issues
#	NoResource was moved from twisted.web.error to twisted.web.resource , so we need to reflect that
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

