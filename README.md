# docker-naxsi-waf-with-ui

# About cutting-edge branch

This docker image is intented to test and understand nxapi/nxtool, the new lerning tool for naxsi logs that attempts to perform the following :

 * Events import : Importing naxsi events into an elasticsearch database
 * Whitelist generation : Generate whitelists, from templates rather than from purely statistical aspects
 * Events management : Allow tagging of events into database to exclude them from wl gen process
 * Reporting : Display information about current DB content


The image  is built from source, using [nginx 1.7.9](http://nginx.org/download/) and  [naxsi](https://github.com/nbs-system/naxsi) master branch.


Elasticsearch isn't provided as part of this docker container, but but you can get official images by running:

    docker run --name my-elastic \
               -p 9100:9100 -p 9200:9200 \
               -d elasticsearch:1.3.7

Keep in mind that data saved to this server won't be persisted between restarts, if you want to do so, follow the [official docs](https://github.com/dockerfile/elasticsearch)

If your elasticsearch is in another host, you must pass the variable ```ELASTICSEARCH_HOST`` to docker.


Naxsi in launched in learning mode, and logs are feed to elasticsearch every five seconds in a non ideal way, due to issues found while using the methods provided to get live logs from nginx to nxtool/nxapi.

Run this image with:

    docker run --env PROXY_REDIRECT_IP=10.0.0.1 \
               --link my-elastic:elasticsearch \
              -p 80:80 -p 8080:8080 \
              -d scollazo/naxsi-waf-with-ui:devel

Use your web, so the database get some data,  and then, go to http://your_host_ip:8080 to see the reports using kibana.

If you find problems, or want to run the nxtool utility to [query the database](https://github.com/nbs-system/naxsi/tree/master/nxapi#simple-usage-approach) you can get a shell by running:

    docker run --env PROXY_REDIRECT_IP=10.0.0.1 \
               --link my-elastic:elasticsearch \
               -p 80:80 -p 8080:8080 \
               --rm scollazo/naxsi-waf-with-ui:devel /bin/bash

You may need to run the /entrypoint.sh by hand, as some configuration values are set by this script.
