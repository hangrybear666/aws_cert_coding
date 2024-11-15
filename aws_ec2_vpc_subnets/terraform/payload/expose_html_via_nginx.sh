#!/bin/bash

echo "<p>Hello World from IPV4 $(curl ifconfig.me) and Hostname $(hostname -f)</p>" > index.html
docker build -t nginx-static-host -f Dockerfile.nginx_static_host .
docker run -d -p 80:80 nginx-static-host