FROM ubuntu:trusty

MAINTAINER Santiago Rodriguez <scollazo@gmail.com>

#Config files and some ideas taken from
# https://github.com/Epheo/docker-naxsi-proxy-waf/

#Change this and build the image to suit your needs by default, without needing to add parameters later
ENV LEARNING_MODE yes
ENV BACKEND_IP 12.34.56.78
ENV ELASTICSEARCH_HOST elasticsearch

#Software versions
ENV NGINX_VERSION 1.9.10
ENV NAXSI_VERSION master

#Install needed packages from repos
RUN apt-get update &&\
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
					    wget python-pip python-geoip logtail curl \
					    gcc make libpcre3-dev libssl-dev \
					    supervisor

#Get nginx and naxsi-ui
RUN cd /usr/local/ && \
    wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" && \
    wget "https://github.com/nbs-system/naxsi/archive/${NAXSI_VERSION}.tar.gz" && \
    tar zxvf nginx-${NGINX_VERSION}.tar.gz && \
    tar zxvf ${NAXSI_VERSION}.tar.gz

#Build and install nginx + naxsi
RUN cd /usr/local/nginx-${NGINX_VERSION}/ && \
    ./configure \
      --conf-path=/etc/nginx/nginx.conf --add-module=../naxsi-${NAXSI_VERSION}/naxsi_src/ \
      --error-log-path=/var/log/nginx/error.log --http-client-body-temp-path=/var/lib/nginx/body \
      --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-log-path=/var/log/nginx/access.log \
      --http-proxy-temp-path=/var/lib/nginx/proxy --lock-path=/var/lock/nginx.lock \
      --pid-path=/var/run/nginx.pid --with-http_ssl_module \
      --without-mail_pop3_module --without-mail_smtp_module \
      --without-mail_imap_module --without-http_uwsgi_module \
      --without-http_scgi_module --with-ipv6 --prefix=/usr && \
     make && \
     make install 

#Install nxapi / nxtool
RUN cd /usr/local/naxsi-${NAXSI_VERSION} && \
     cp naxsi_config/naxsi_core.rules /etc/nginx/ && \
     cd nxapi && \
     pip install -r requirements.txt && \
     python setup.py install

#Configuration files
ADD nginx/nginx.conf /etc/nginx/nginx.conf
ADD nginx/sites-enabled/* /etc/nginx/sites-enabled/
ADD naxsi/naxsi.rules /etc/nginx/naxsi.rules
ADD naxsi/nxapi.json /usr/local/etc/nxapi.json
RUN mkdir /etc/nginx/naxsi-local-rules
RUN mkdir -p /var/lib/nginx/body
RUN mkdir -p /var/log/supervisor
RUN mkdir -p /etc/supervisor/conf.d/
ADD supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD supervisor/conf.d/* /etc/supervisor/conf.d/

#Ports
EXPOSE 80
EXPOSE 8080

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 755 /docker-entrypoint.sh

CMD ["/docker-entrypoint.sh"]
