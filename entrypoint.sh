#!/bin/bash
#Check for local config files
if [ "$(find /etc/nginx/local-config -type f)" != "" ] 
	 then 
	sed -i 's%include /etc/nginx/naxsi.rules;%include /etc/nginx/naxsi.rules;\n\t\tinclude /etc/nginx/local-rules/*;%g' /etc/nginx/sites-enabled/default

	 fi

if [ x${PROXY_REDIRECT_IP} = x"12.34.56.78" ] 
	then
	echo "You need to set the PROXY_REDIRECT_IP"
	echo "Run with:"
	echo "    docker run -e PROXY_REDIRECT_IP=<your_backend_ip> -p 80:80 -p 8081:8081 scollazo/bla"
	exit 1
else
	sed -i "s#proxy_redirect_ip#${PROXY_REDIRECT_IP}#" /etc/nginx/sites-enabled/default
fi

echo  "Naxsi filtering requests to $PROXY_REDIRECT_IP"

if [ x${LEARNING_MODE} != x"yes" ] 
	then
	sed -i 's/LearningMode;//g' /etc/nginx/naxsi.rules
	echo "LearningMode is disabled - Blocking requests"
	else
	echo "LearningMode is enabled"
fi

if ! [ x${NAXSI_UI_PASSWORD} != x"test" ] 
	then
	sed -i "s/test/${NAXSI_UI_PASSWORD}/" /usr/local/naxsi/contrib/naxsi-ui/naxsi-ui.conf
fi
echo "naxsi-ui user: naxsi_web"
echo "naxsi-ui password: ${NAXSI_UI_PASSWORD}"

#Change owner for log files
if [ -d /var/log/nginx ]
	then
	chown www-data.www-data /var/log/nginx -R
	fi


cd /usr/local/naxsi/contrib/naxsi-ui

python nx_extract.py -c naxsi-ui.conf
python nx_intercept.py -c naxsi-ui.conf
nginx -c /etc/nginx/nginx.conf
