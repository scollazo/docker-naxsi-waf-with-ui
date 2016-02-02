# docker-naxsi-waf-with-ui

# About cutting-edge branch

Run the latest version of the [naxsi WAF](https://github.com/nbs-system/naxsi), with the ability to analyze the data set by using the searching/aggregation capabilities of Elasticseach and the visualization power of Kibana

This docker image is intented to test and understand nxapi/nxtool, the new lerning tool for naxsi logs that attempts to perform the following :

 * Events import : Importing naxsi events into an elasticsearch database
 * Whitelist generation : Generate whitelists, from templates rather than from purely statistical aspects
 * Events management : Allow tagging of events into database to exclude them from wl gen process
 * Reporting : Display information about current DB content


The image  is built from source, using [nginx 1.9.10](http://nginx.org/download/) and  [naxsi](https://github.com/nbs-system/naxsi) master branch.

# Requirements

## Setup

1. Install [Docker](http://docker.io).
2. Install [Docker-compose](http://docs.docker.com/compose/install/).
3. Clone this repository
4. Edit the docker-compose.yml and set the ``BACKEND_IP`` to the server that will be protected by naxsi.

# Usage

Start the stack using *docker-compose*:

```bash
$ docker-compose up
```

You can also choose to run it in background (detached mode):

```bash
$ docker-compose up -d
```

By default, the stack exposes the following ports:
* 80: Nginx with Naxsi, forwarding requests to BACKEND_IP
* 5000: Logstash TCP input.
* 9200: Elasticsearch HTTP
* 9300: Elasticsearch TCP transport
* 5601: Kibana


Naxsi in launched in learning mode, and logs are feed to elasticsearch every five seconds in a non ideal way, due to issues found while using the methods provided to get live logs from nginx to nxtool/nxapi.


Use your web, so the database get some data,  and then, go to http://your_host_ip:5601 to see the reports using kibana.

The data stored in Elasticsearch is persisted in ``./elasticsearch-data`` directory . This can be changed in docker-compose.yml

If you find problems, or want to run the nxtool utility to [query the database](https://github.com/nbs-system/naxsi/tree/master/nxapi#simple-usage-approach) you can get a shell by running:

    docker ps # Identify naxsi container id
    docker exec -i -t <CONTAINER_ID> /bin/bash
