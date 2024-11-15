#!/bin/bash

echo "<p>Hello World from <br>IPV4 [$(curl ifconfig.me)] <br>Hostname [$(hostname -f)] <br>InstanceNum [$1]</p>" > index.html
docker build -t nginx-static-host -f Dockerfile.nginx_static_host .
docker run -d -p 80:80 nginx-static-host