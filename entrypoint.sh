#!/bin/bash
#Check for local config files
if [ "$(find /etc/nginx/local-config -type f)" != "" ] 
	 then 
	sed -i 's%include /etc/nginx/naxsi.rules;%include /etc/nginx/naxsi.rules;\n\t\tinclude /etc/nginx/local-rules/*;%g' /etc/nginx/sites-enabled/default
	 fi


#Check if we are asked to process old logs

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

if [ x${ELASTICSEARCH_HOST} !=  x"elasticsearch" ]
	then
	sed -i "s/elasticsearch/${ELASTICSEARCH_HOST}/g" /usr/local/etc/nxapi.json
	fi
#if [ x${KIBANA_PASSWORD} != x"popo" ] 
#	then
#	#sed -i 's/LearningMode;//g' /etc/nginx/naxsi.rules
#	PASS=
#	echo "LearningMode is disabled - Blocking requests"
#	else
#	echo "LearningMode is enabled"
#fi

#Change owner for log files
if [ -d /var/log/nginx ]
	then
	chown www-data.www-data /var/log/nginx -R
	fi

echo "naxsi log collection disabled"
#nxtool.py --fifo=/var/log/nginx/naxsi-fifo > /dev/null 2>&1 &
nginx -c /etc/nginx/nginx.conf &

## Ugly hack, but I don't know how to get live logs from nginx to nxtool
## --stdin goes crazy (infinite loop)
## --fifo goes crazy too 
## --syslog didn't work for me with nginx 1.7.9 and
## 	nginx.conf: error_log syslog=localhost:51400 debug;
## So I used logtail, and --file
sh -c 'while $(pidof nginx > /dev/null) 
	 do 
	 logtail /var/log/nginx/error.log > current && nxtool.py --file=current && rm -f current
	 sleep 5
	 done'



